import '../../../../core/error/exceptions.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

/// Use case for fetching all notifications
///
/// This is a pure domain use case with no Flutter dependencies.
class GetNotifications {
  final NotificationRepository repository;

  const GetNotifications(this.repository);

  /// Executes the use case and returns all notifications
  ///
  /// Returns a list of notifications sorted by timestamp (newest first).
  /// Throws a [StorageException] if the repository operation fails.
  Future<List<NotificationEntity>> call() async {
    try {
      return await repository.getNotifications();
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to fetch notifications: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

