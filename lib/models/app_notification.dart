enum NotificationType {
  newDonation,
  requestApproved,
  requestRejected,
  pickupReminder,
  collectionConfirmed,
}

extension NotificationTypeText on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.newDonation:
        return 'New Donation';
      case NotificationType.requestApproved:
        return 'Request Approved';
      case NotificationType.requestRejected:
        return 'Request Rejected';
      case NotificationType.pickupReminder:
        return 'Pickup Reminder';
      case NotificationType.collectionConfirmed:
        return 'Collection Confirmed';
    }
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    this.relatedId,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  // Optional link back to a donation or request record.
  final String? relatedId;

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? relatedId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'relatedId': relatedId,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: NotificationType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => NotificationType.newDonation,
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      relatedId: json['relatedId'] as String?,
    );
  }
}
