// frontend/lib/presentation/tabs/events_tab.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/common/message_type.dart';
import 'package:frontend/presentation/widgets/common/common_responsive_breakpoints.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';
import 'package:frontend/presentation/widgets/common/common_empty_state_message.dart';
import 'package:frontend/presentation/widgets/common/common_search_bar.dart';
import 'package:frontend/presentation/widgets/common/common_section_title.dart';
import 'package:frontend/presentation/providers/event_provider.dart';
import 'package:frontend/presentation/widgets/home_screen/tabs/widgets/event_list_item.dart';
import 'package:frontend/presentation/widgets/common/common_featured_event_card.dart';
import 'package:frontend/presentation/widgets/common/common_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class EventsTab extends StatefulWidget {
  const EventsTab({super.key});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  late Future<void> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final provider = context.read<EventProvider>();
    await Future.wait([
      provider.fetchFeaturedEvents(1, 5),
      provider.filterEvents({'upcoming': true}, 1, 10),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = context.isWeb;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.eventsTitle),
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
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: const EventsContent(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/events/create'),
        tooltip: AppTexts.createEventTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    _dataFuture = _loadInitialData();
    await _dataFuture;
    if (mounted) {
      context.showSuccessSnackBar(AppTexts.refreshSuccess);
    }
  }
}

class EventsContent extends StatelessWidget {
  const EventsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildFeaturedEventsSection(context),
        _buildSearchAndFilterSection(context),
        _buildAllEventsSection(context),
        SliverPadding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).size.height * 0.1, // 10% of the height
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedEventsSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: CommonSectionTitle(
              title: AppTexts.featuredEvents,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
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

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: events.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return SizedBox(
                      width: 250,
                      child: CommonFeaturedEventCard(
                        event: event,
                        onTap: () => context.push('/events/${event.id}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: CommonSearchBar(
          hintText: AppTexts.searchEventsHint,
          onChanged: (value) {
            final provider = context.read<EventProvider>();
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
    );
  }

  Widget _buildAllEventsSection(BuildContext context) {
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
              if (index >= events.length) {
                return const SizedBox.shrink();
              }
              final event = events[index];
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      MediaQuery.of(context).size.width >= 800 ? 24 : 16,
                  vertical: MediaQuery.of(context).size.width >= 800 ? 12 : 8,
                ),
                child: EventListItem(
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
