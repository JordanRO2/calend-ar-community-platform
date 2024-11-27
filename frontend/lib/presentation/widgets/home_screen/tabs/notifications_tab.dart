import 'package:flutter/material.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';
import 'package:frontend/presentation/widgets/common/common_empty_state_message.dart';
import 'package:frontend/presentation/providers/notification_provider.dart';
import 'package:frontend/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/widgets/common/common_snackbar.dart';
import 'package:frontend/domain/entities/notification.dart' as domain;
import 'package:frontend/presentation/widgets/common/common_loading_indicator.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  final ScrollController _scrollController = ScrollController();
  static const _pageSize = 20;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  late Future<void> _initialLoad;

  @override
  void initState() {
    super.initState();
    _initialLoad = _loadInitialData();
    _setupScrollListener();
  }

  Future<void> _loadInitialData() async {
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.currentUser?.id;

    if (userId != null) {
      await context.read<NotificationProvider>().fetchNotificationsByUser(
            userId,
            page: 1,
            limit: _pageSize,
          );
      _currentPage = 1;
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.8 &&
          !_isLoadingMore) {
        _loadMoreNotifications();
      }
    });
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoadingMore) return;

    final userProvider = context.read<UserProvider>();
    final userId = userProvider.currentUser?.id;

    if (userId != null) {
      setState(() {
        _isLoadingMore = true;
      });

      final nextPage = _currentPage + 1;

      try {
        await context.read<NotificationProvider>().fetchNotificationsByUser(
              userId,
              page: nextPage,
              limit: _pageSize,
            );
        _currentPage = nextPage;
      } catch (e) {
        context.showErrorSnackBar(AppTexts.errorLoadingMoreNotifications);
      } finally {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _loadInitialData();
    if (mounted) {
      context.showSuccessSnackBar(AppTexts.refreshSuccess);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.notificationsTitle),
        actions: [
          IconButton(
            onPressed: _handleRefresh,
            icon: const Icon(Icons.refresh),
            tooltip: AppTexts.refreshTooltip,
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initialLoad,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CommonLoadingIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(AppTexts.errorLoadingNotifications),
            );
          }

          return Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              final notifications = provider.notifications;

              if (notifications.isEmpty) {
                return const CommonEmptyStateMessage(
                  message: AppTexts.noNotificationsMessage,
                  icon: Icons.notifications_off_outlined,
                );
              }

              return RefreshIndicator(
                onRefresh: _handleRefresh,
                child: NotificationsContent(
                  scrollController: _scrollController,
                  isLoadingMore: _isLoadingMore,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationsContent extends StatelessWidget {
  final ScrollController scrollController;
  final bool isLoadingMore;

  const NotificationsContent({
    super.key,
    required this.scrollController,
    required this.isLoadingMore,
  });

  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<NotificationProvider>().notifications;

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == notifications.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CommonLoadingIndicator(),
            ),
          );
        }

        final notification = notifications[index];
        return NotificationCardWidget(
          notification: notification,
          onDismiss: () => _handleDismissNotification(context, notification),
          onTap: () => _handleNotificationTap(context, notification),
        );
      },
    );
  }

  Future<void> _handleDismissNotification(
      BuildContext context, domain.Notification notification) async {
    try {
      await context
          .read<NotificationProvider>()
          .deleteNotification(notification.id);
      if (context.mounted) {
        context.showSuccessSnackBar(AppTexts.notificationDismissed);
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(AppTexts.errorDismissingNotification);
      }
    }
  }

  void _handleNotificationTap(
      BuildContext context, domain.Notification notification) {
    if (notification.status == "unread") {
      context.read<NotificationProvider>().markAsRead(notification.id);
    }
  }
}

class NotificationCardWidget extends StatelessWidget {
  final domain.Notification notification;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const NotificationCardWidget({
    super.key,
    required this.notification,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = notification.status == "unread";

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        color: theme.colorScheme.error,
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDismiss(),
      child: Card(
        color: isUnread
            ? theme.colorScheme.primary.withOpacity(0.1)
            : theme.colorScheme.surface,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _getNotificationIcon(notification.type, theme),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isUnread ? FontWeight.bold : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(notification.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUnread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getNotificationIcon(String type, ThemeData theme) {
    IconData iconData;
    Color color;

    switch (type) {
      case 'event':
        iconData = Icons.event;
        color = theme.colorScheme.primary;
        break;
      case 'comment':
        iconData = Icons.comment;
        color = Colors.blue;
        break;
      case 'reminder':
        iconData = Icons.alarm;
        color = Colors.orange;
        break;
      default:
        iconData = Icons.notifications;
        color = theme.colorScheme.secondary;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: color,
        size: 24,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
