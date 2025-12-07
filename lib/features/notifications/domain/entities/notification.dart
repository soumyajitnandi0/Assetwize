import 'package:equatable/equatable.dart';

/// Notification entity representing a user notification
/// This is a pure domain entity with no Flutter dependencies
class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.metadata,
  });

  /// Creates a copy with updated fields
  NotificationEntity copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        type,
        timestamp,
        isRead,
        metadata,
      ];
}

/// Types of notifications
enum NotificationType {
  assetAdded,
  profileUpdated,
  insuranceExpiring,
  insuranceExpired,
  general,
}

