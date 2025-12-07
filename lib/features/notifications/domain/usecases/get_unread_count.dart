import '../../../../core/error/exceptions.dart';
import '../repositories/notification_repository.dart';

/// Use case for fetching unread notification count
///
/// This is a pure domain use case with no Flutter dependencies.
class GetUnreadCount {
  final NotificationRepository repository;

  const GetUnreadCount(this.repository);

  /// Executes the use case and returns unread count
  ///
  /// Returns the number of unread notifications.
  /// Throws a [StorageException] if the repository operation fails.
  Future<int> call() async {
    try {
      return await repository.getUnreadCount();
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to fetch unread count: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

