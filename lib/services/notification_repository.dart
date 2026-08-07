import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_notification.dart';

class NotificationRepository extends ChangeNotifier {
  static const _storageKey = 'communitycare_notifications';

  final List<AppNotification> _notifications = [];
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  List<AppNotification> get notifications {
    final sorted = List<AppNotification>.from(_notifications);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List.unmodifiable(sorted);
  }

  int get unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  Future<void> load({bool seedDemoData = false}) async {
    final storedJson = await _preferences.getString(_storageKey);

    _notifications.clear();

    if (storedJson != null) {
      final decoded = jsonDecode(storedJson) as List<dynamic>;
      _notifications.addAll(
        decoded.map(
          (item) => AppNotification.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        ),
      );
    } else if (seedDemoData) {
      _notifications.addAll(_buildDemoNotifications());
      await _save();
    }

    notifyListeners();
  }

  Future<void> addNotification(AppNotification notification) async {
    _notifications.add(notification);
    await _saveAndNotify();
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere(
      (notification) => notification.id == notificationId,
    );

    if (index == -1) return;

    _notifications[index] = _notifications[index].copyWith(isRead: true);
    await _saveAndNotify();
  }

  Future<void> markAllAsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    await _saveAndNotify();
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere(
      (notification) => notification.id == notificationId,
    );
    await _saveAndNotify();
  }

  Future<void> _saveAndNotify() async {
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final encoded = jsonEncode(
      _notifications.map((notification) => notification.toJson()).toList(),
    );
    await _preferences.setString(_storageKey, encoded);
  }

  List<AppNotification> _buildDemoNotifications() {
    final now = DateTime.now();

    return [
      AppNotification(
        id: 'notif-1',
        type: NotificationType.newDonation,
        title: 'New donation nearby',
        message: 'Garden Salad was just added near you.',
        timestamp: now.subtract(const Duration(minutes: 20)),
        isRead: false,
        relatedId: 'demo-1',
      ),
      AppNotification(
        id: 'notif-2',
        type: NotificationType.requestApproved,
        title: 'Request approved',
        message: 'Your request for Cooked Pasta was approved.',
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: false,
        relatedId: 'demo-2',
      ),
      AppNotification(
        id: 'notif-3',
        type: NotificationType.pickupReminder,
        title: 'Pickup reminder',
        message: 'Collect Whole Grain Bread by 6:00 PM today.',
        timestamp: now.subtract(const Duration(hours: 20)),
        isRead: true,
        relatedId: 'demo-3',
      ),
      AppNotification(
        id: 'notif-4',
        type: NotificationType.collectionConfirmed,
        title: 'Collection confirmed',
        message: 'Thanks for collecting Yogurt Cups. 8 meals shared!',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
        relatedId: 'demo-4',
      ),
    ];
  }
}
