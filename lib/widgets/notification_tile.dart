import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/app_notification.dart';
import '../utils/app_theme.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.newDonation:
        return Icons.volunteer_activism;
      case NotificationType.requestApproved:
        return Icons.check_circle;
      case NotificationType.requestRejected:
        return Icons.cancel;
      case NotificationType.pickupReminder:
        return Icons.access_time_filled;
      case NotificationType.collectionConfirmed:
        return Icons.task_alt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Material(
        color: isUnread ? AppTheme.softGreen : Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.darkGreen,
                  child: Icon(_icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight:
                              isUnread ? FontWeight.w700 : FontWeight.w500,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          color: AppTheme.textDark.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('MMM d, h:mm a')
                            .format(notification.timestamp),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUnread)
                  Container(
                    margin: const EdgeInsets.only(left: 8, top: 4),
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppTheme.warmOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
