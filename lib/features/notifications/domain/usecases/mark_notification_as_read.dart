import '../../../../core/error/exceptions.dart';
import '../repositories/notification_repository.dart';

/// Use case for marking a notification as read
///
/// This is a pure domain use case with no Flutter dependencies.
class MarkNotificationAsRead {
  final NotificationRepository repository;

  const MarkNotificationAsRead(this.repository);

  /// Executes the use case and marks the notification as read
  ///
  /// [notificationId] - The ID of the notification to mark as read
  /// Throws [ValidationException] if notificationId is empty
  /// Throws [NotFoundException] if notification is not found
  /// Throws [StorageException] if the operation fails
  Future<void> call(String notificationId) async {
    if (notificationId.isEmpty) {
      throw const ValidationException('Notification ID cannot be empty');
    }

    try {
      await repository.markAsRead(notificationId);
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to mark notification as read: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

