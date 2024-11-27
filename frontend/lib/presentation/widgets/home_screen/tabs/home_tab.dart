// frontend/lib/presentation/tabs/home_tab.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/common/message_type.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/presentation/widgets/common/common_empty_state_message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/presentation/widgets/common/common_featured_event_card.dart';
import 'package:frontend/presentation/widgets/common/common_featured_community_card.dart';
import 'package:frontend/presentation/widgets/common/common_search_bar.dart';
import 'package:frontend/presentation/widgets/common/common_section_title.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';
import 'package:frontend/presentation/providers/event_provider.dart';
import 'package:frontend/presentation/providers/community_provider.dart';
import 'package:frontend/domain/entities/event.dart';
import 'package:frontend/presentation/configuration/assets/app_images.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _isLoading = true;
  String? _error;

  // Track if the widget is still mounted during asynchronous operations
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      if (_isDisposed) return;

      // Set loading state
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      // Perform asynchronous data fetching
      await Future.wait([
        Provider.of<EventProvider>(context, listen: false)
            .fetchFeaturedEvents(1, 5),
        Provider.of<EventProvider>(context, listen: false)
            .filterEvents({'upcoming': true}, 1, 10),
        Provider.of<CommunityProvider>(context, listen: false)
            .fetchFeaturedCommunities(1, 3),
        Provider.of<CommunityProvider>(context, listen: false)
            .fetchAllCommunities(1, 10),
      ]);
    } catch (e) {
      if (_isDisposed) return;

      // Handle errors
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (_isDisposed) return;

      // Reset loading state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _loadData();
    if (_isDisposed) return;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppTexts.refreshSuccess),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    // Mark the widget as disposed to prevent setState calls
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar los datos: $_error',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: const _HomeContent(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/events/create'),
        tooltip: AppTexts.createEventTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        _buildFeaturedCommunitiesSection(context),
        _buildFeaturedEventsSection(context),
        _buildUpcomingEventsSection(context),
        _buildUpcomingEventsList(context),
        SliverPadding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).size.height * 0.1, // 10% de la altura
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      title: const Text(AppTexts.homeTitle),
      bottom: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CommonSearchBar(
            hintText: AppTexts.searchEventsHint,
            onChanged: (value) {
              final provider =
                  Provider.of<EventProvider>(context, listen: false);
              if (value.length >= 3) {
                provider.filterEvents(
                  {'search': value},
                  1,
                  10,
                );
              } else if (value.isEmpty) {
                // Reset filters when search is cleared
                provider.filterEvents(
                  {},
                  1,
                  10,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCommunitiesSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth >= 800;
          final crossAxisCount = isLargeScreen ? 3 : 1;
          const spacing = 16.0;
          const totalHorizontalPadding = 32.0; // 16 left + 16 right
          final cardWidth = isLargeScreen
              ? (constraints.maxWidth -
                      totalHorizontalPadding -
                      (crossAxisCount - 1) * spacing) /
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
                      // Large screens: GridView
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
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
                      // Small screens: Horizontal ListView
                      return SizedBox(
                        height: cardHeight,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: communities.length,
                          itemBuilder: (context, index) {
                            final community = communities[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                  right: index < communities.length - 1
                                      ? spacing
                                      : 0),
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

  Widget _buildFeaturedEventsSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth >= 800;
          final crossAxisCount = isLargeScreen ? 3 : 1;
          const spacing = 16.0;
          const totalHorizontalPadding = 32.0; // 16 left + 16 right
          final cardWidth = isLargeScreen
              ? (constraints.maxWidth -
                      totalHorizontalPadding -
                      (crossAxisCount - 1) * spacing) /
                  crossAxisCount
              : 300.0;
          final cardHeight = isLargeScreen ? 300.0 : 200.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: CommonSectionTitle(title: AppTexts.featuredEvents),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Consumer<EventProvider>(
                  builder: (context, provider, _) {
                    final events = provider.featuredEvents;
                    final isLoading = provider.isLoading;
                    final message = provider.message;
                    final messageType = provider.messageType;

                    if (isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (message != null &&
                        messageType == MessageType.error) {
                      return Center(
                        child: Text('Error: $message'),
                      );
                    } else if (events.isEmpty) {
                      return const CommonEmptyStateMessage(
                        message: AppTexts.noFeaturedEventsMessage,
                      );
                    }

                    if (isLargeScreen) {
                      // Large screens: GridView
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          childAspectRatio: cardWidth / cardHeight,
                        ),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return CommonFeaturedEventCard(
                            event: event,
                            onTap: () => context.push('/events/${event.id}'),
                          );
                        },
                      );
                    } else {
                      // Small screens: Horizontal ListView
                      return SizedBox(
                        height: cardHeight,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                  right:
                                      index < events.length - 1 ? spacing : 0),
                              child: SizedBox(
                                width: cardWidth,
                                height: cardHeight,
                                child: CommonFeaturedEventCard(
                                  event: event,
                                  onTap: () =>
                                      context.push('/events/${event.id}'),
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

  Widget _buildUpcomingEventsSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical:
              MediaQuery.of(context).size.height * 0.03, // Relative spacing
        ),
        child: const CommonSectionTitle(title: AppTexts.upcomingEvents),
      ),
    );
  }

  Widget _buildUpcomingEventsList(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        final events = provider.events;
        final isLoading = provider.isLoading;
        final message = provider.message;
        final messageType = provider.messageType;

        if (isLoading) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (message != null && messageType == MessageType.error) {
          return SliverToBoxAdapter(
            child: Center(
              child: Text('Error: $message'),
            ),
          );
        } else if (events.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: CommonEmptyStateMessage(
              message: AppTexts.noUpcomingEventsMessage,
              icon: Icons.event_busy,
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final event = events[index];
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      MediaQuery.of(context).size.width >= 800 ? 24 : 16,
                  vertical: MediaQuery.of(context).size.width >= 800 ? 12 : 8,
                ),
                child: _EventListItem(
                  event: event,
                  onTap: () => context.push('/events/${event.id}'),
                ),
              );
            },
            childCount: events.length,
          ),
        );
      },
    );
  }
}

class _EventListItem extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _EventListItem({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 800;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02), // 2% of width
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: event.imageUrl ?? AppImages.defaultEvent,
                  width: isLargeScreen ? 160 : 120,
                  height: isLargeScreen ? 160 : 120,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: isLargeScreen ? 160 : 120,
                    height: isLargeScreen ? 160 : 120,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.event,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: isLargeScreen ? 40 : 30,
                    ),
                  ),
                  placeholder: (_, __) => Container(
                    width: isLargeScreen ? 160 : 120,
                    height: isLargeScreen ? 160 : 120,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.event,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: isLargeScreen ? 40 : 30,
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.02), // 2% of width
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with 2 lines
                    Text(
                      event.title,
                      style: isLargeScreen
                          ? theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            )
                          : theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isLargeScreen ? 12 : 8),
                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: isLargeScreen
                                ? theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.black54,
                                  )
                                : theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.black54,
                                  ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isLargeScreen ? 8 : 4),
                    // Date and Time
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatDateTime(event.dateTime),
                            style: isLargeScreen
                                ? theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.black54,
                                  )
                                : theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.black54,
                                  ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    // Format the date and time as desired
    return '${_twoDigits(dateTime.day)}/${_twoDigits(dateTime.month)}/${dateTime.year} '
        '${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
