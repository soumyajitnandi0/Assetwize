import '../../domain/entities/notification.dart';

/// Notification model extending the domain entity
/// Handles data serialization/deserialization
class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.type,
    required super.timestamp,
    super.isRead,
    super.metadata,
  });

  /// Creates a NotificationModel from a JSON map
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.general,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts NotificationModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'metadata': metadata,
    };
  }

  /// Creates a NotificationModel from a domain NotificationEntity
  factory NotificationModel.fromEntity(NotificationEntity notification) {
    return NotificationModel(
      id: notification.id,
      title: notification.title,
      message: notification.message,
      type: notification.type,
      timestamp: notification.timestamp,
      isRead: notification.isRead,
      metadata: notification.metadata,
    );
  }
}

