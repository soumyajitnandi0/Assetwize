import '../../../../core/error/exceptions.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

/// Use case for adding a new notification
///
/// This is a pure domain use case with no Flutter dependencies.
class AddNotification {
  final NotificationRepository repository;

  const AddNotification(this.repository);

  /// Executes the use case and adds the notification
  ///
  /// [notification] - The notification to add
  /// Throws [ValidationException] if notification is invalid
  /// Throws [StorageException] if the operation fails
  Future<void> call(NotificationEntity notification) async {
    if (notification.id.isEmpty) {
      throw const ValidationException('Notification ID cannot be empty');
    }
    if (notification.title.isEmpty) {
      throw const ValidationException('Notification title cannot be empty');
    }
    if (notification.message.isEmpty) {
      throw const ValidationException('Notification message cannot be empty');
    }

    try {
      await repository.addNotification(notification);
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to add notification: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

