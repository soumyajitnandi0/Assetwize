import '../entities/notification.dart';

/// Abstract repository interface for notification data
abstract class NotificationRepository {
  /// Fetches all notifications
  /// Returns a list of NotificationEntity, sorted by timestamp (newest first)
  Future<List<NotificationEntity>> getNotifications();

  /// Fetches unread notifications count
  Future<int> getUnreadCount();

  /// Marks a notification as read
  Future<void> markAsRead(String notificationId);

  /// Marks all notifications as read
  Future<void> markAllAsRead();

  /// Adds a new notification
  Future<void> addNotification(NotificationEntity notification);

  /// Deletes a notification
  Future<void> deleteNotification(String notificationId);

  /// Clears all notifications
  Future<void> clearAll();
}

