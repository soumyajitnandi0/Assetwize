import '../../../../core/error/exceptions.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

/// Use case for creating a profile updated notification
///
/// This is a pure domain use case with no Flutter dependencies.
/// Creates a notification when profile details are updated.
class NotifyProfileUpdated {
  final NotificationRepository repository;

  const NotifyProfileUpdated(this.repository);

  /// Executes the use case and creates the notification
  ///
  /// [fieldName] - The name of the field that was updated
  /// Throws [ValidationException] if fieldName is empty
  /// Throws [StorageException] if the operation fails
  Future<void> call(String fieldName) async {
    if (fieldName.trim().isEmpty) {
      throw const ValidationException('Field name cannot be empty');
    }

    try {
      final notification = NotificationEntity(
        id: _generateId(),
        title: 'Profile Updated',
        message: 'Your $fieldName has been successfully updated.',
        type: NotificationType.profileUpdated,
        timestamp: DateTime.now(),
        metadata: {
          'fieldName': fieldName,
        },
      );

      await repository.addNotification(notification);
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to create profile updated notification: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Generates a unique ID for the notification
  String _generateId() {
    return 'notif_${DateTime.now().millisecondsSinceEpoch}_profile';
  }
}

