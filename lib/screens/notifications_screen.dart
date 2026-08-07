import 'package:flutter/material.dart';

import '../services/notification_repository.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    required this.notificationRepository,
  });

  final NotificationRepository notificationRepository;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.notificationRepository,
      builder: (context, _) {
        final notifications = widget.notificationRepository.notifications;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            actions: [
              if (notifications.isNotEmpty)
                TextButton(
                  onPressed: widget.notificationRepository.unreadCount == 0
                      ? null
                      : widget.notificationRepository.markAllAsRead,
                  child: const Text(
                    'Mark All as Read',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
          body: notifications.isEmpty
              ? const _EmptyNotifications()
              : ListView.separated(
                  itemCount: notifications.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return NotificationTile(
                      notification: notification,
                      onTap: () => widget.notificationRepository
                          .markAsRead(notification.id),
                      onDelete: () => widget.notificationRepository
                          .deleteNotification(notification.id),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            const Text(
              'No notifications yet',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Donation alerts, request updates and pickup reminders '
              'will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
