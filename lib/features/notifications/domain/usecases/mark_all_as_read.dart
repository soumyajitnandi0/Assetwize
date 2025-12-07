import '../../../../core/error/exceptions.dart';
import '../repositories/notification_repository.dart';

/// Use case for marking all notifications as read
///
/// This is a pure domain use case with no Flutter dependencies.
class MarkAllAsRead {
  final NotificationRepository repository;

  const MarkAllAsRead(this.repository);

  /// Executes the use case and marks all notifications as read
  ///
  /// Throws [StorageException] if the operation fails
  Future<void> call() async {
    try {
      await repository.markAllAsRead();
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to mark all notifications as read: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

