// frontend/lib/presentation/tabs/communities_tab.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/common/message_type.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';
import 'package:frontend/presentation/widgets/common/common_empty_state_message.dart';
import 'package:frontend/presentation/widgets/common/common_search_bar.dart';
import 'package:frontend/presentation/widgets/common/common_section_title.dart';
import 'package:frontend/presentation/providers/community_provider.dart';
import 'package:frontend/presentation/widgets/common/common_featured_community_card.dart';
import 'package:frontend/presentation/widgets/common/common_community_list_item.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/presentation/widgets/common/common_snackbar.dart';

class CommunitiesTab extends StatefulWidget {
  const CommunitiesTab({super.key});

  @override
  State<CommunitiesTab> createState() => _CommunitiesTabState();
}

class _CommunitiesTabState extends State<CommunitiesTab> {
  late Future<void> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final provider = context.read<CommunityProvider>();
    await Future.wait([
      provider.fetchFeaturedCommunities(
          1, 3), // Asegurando 3 comunidades destacadas
      provider.fetchAllCommunities(1, 10),
    ]);
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _dataFuture = _loadInitialData();
    });
    await _dataFuture;
    if (mounted) {
      context.showSuccessSnackBar(AppTexts.refreshSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.communitiesTitle),
        actions: [
          if (isWeb)
            IconButton(
              onPressed: _handleRefresh,
              icon: const Icon(Icons.refresh),
              tooltip: AppTexts.refreshTooltip,
            ),
        ],
      ),
      body: FutureBuilder(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Indicador de carga mientras se cargan los datos
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Mostrar error si ocurre alguno durante la carga
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            // Mostrar el contenido una vez que los datos se han cargado
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: const _CommunitiesContent(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/communities/create'),
        tooltip: AppTexts.createCommunityTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CommunitiesContent extends StatelessWidget {
  const _CommunitiesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildFeaturedCommunitiesSection(context),
        _buildSearchAndFilterSection(context),
        _buildAllCommunitiesSection(context),
        SliverPadding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).size.height * 0.1, // 10% de la altura
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCommunitiesSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth >= 800;
          final crossAxisCount = isLargeScreen ? 3 : 1;
          final cardWidth = isLargeScreen
              ? (constraints.maxWidth - 32 - (crossAxisCount - 1) * 16) /
                  crossAxisCount
              : 300.0;
          final cardHeight = isLargeScreen ? 300.0 : 200.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child:
                    CommonSectionTitle(title: AppTexts.communitiesSectionTitle),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Consumer<CommunityProvider>(
                  builder: (context, provider, _) {
                    final communities = provider.featuredCommunities;

                    if (communities.isEmpty) {
                      return const CommonEmptyStateMessage(
                        message: AppTexts.noCommunitiesFoundMessage,
                      );
                    }

                    if (isLargeScreen) {
                      // Pantallas grandes: GridView
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: cardWidth / cardHeight,
                        ),
                        itemCount: communities.length,
                        itemBuilder: (context, index) {
                          final community = communities[index];
                          return CommonFeaturedCommunityCard(
                            community: community,
                            onTap: () =>
                                context.push('/communities/${community.id}'),
                          );
                        },
                      );
                    } else {
                      // Pantallas pequeñas: ListView horizontal
                      return SizedBox(
                        height: cardHeight,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: communities.length,
                          itemBuilder: (context, index) {
                            final community = communities[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                  right:
                                      index < communities.length - 1 ? 16 : 0),
                              child: SizedBox(
                                width: cardWidth,
                                height: cardHeight,
                                child: CommonFeaturedCommunityCard(
                                  community: community,
                                  onTap: () => context
                                      .push('/communities/${community.id}'),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilterSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: CommonSearchBar(
          hintText: AppTexts.searchCommunitiesHint,
          onChanged: (value) {
            if (value.length >= 3) {
              context.read<CommunityProvider>().filterCommunities(
                {'search': value},
                1,
                10,
              );
            } else if (value.isEmpty) {
              // Resetear filtros cuando la búsqueda se borra
              context.read<CommunityProvider>().filterCommunities(
                {'search': value, 'type': '', 'category': '', 'location': ''},
                1,
                10,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildAllCommunitiesSection(BuildContext context) {
    return Consumer<CommunityProvider>(
      builder: (context, provider, _) {
        final communities = provider.communities;
        final isLoading = provider.isLoading;
        final message = provider.message;
        final messageType = provider.messageType;

        if (isLoading) {
          // Indicador de carga dentro de la sección de comunidades
          return SliverToBoxAdapter(
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (message != null && messageType == MessageType.error) {
          return SliverToBoxAdapter(
            child: Center(
              child: Text('Error: $message'),
            ),
          );
        } else if (communities.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: CommonEmptyStateMessage(
              message: AppTexts.noCommunitiesMessage,
              icon: Icons.people_outline,
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final community = communities[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: CommonCommunityListItem(
                  community: community,
                  onTap: () => context.push('/communities/${community.id}'),
                ),
              );
            },
            childCount: communities.length,
          ),
        );
      },
    );
  }
}
