import '../../../../core/error/exceptions.dart';
import '../repositories/notification_repository.dart';

/// Use case for deleting a notification
///
/// This is a pure domain use case with no Flutter dependencies.
class DeleteNotification {
  final NotificationRepository repository;

  const DeleteNotification(this.repository);

  /// Executes the use case and deletes the notification
  ///
  /// [notificationId] - The ID of the notification to delete
  /// Throws [ValidationException] if notificationId is empty
  /// Throws [StorageException] if the operation fails
  Future<void> call(String notificationId) async {
    if (notificationId.isEmpty) {
      throw const ValidationException('Notification ID cannot be empty');
    }

    try {
      await repository.deleteNotification(notificationId);
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to delete notification: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

