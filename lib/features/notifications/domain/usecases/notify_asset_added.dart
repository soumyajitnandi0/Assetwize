import '../../../../core/error/exceptions.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

/// Use case for creating an asset added notification
///
/// This is a pure domain use case with no Flutter dependencies.
/// Creates a notification when a new asset is added.
class NotifyAssetAdded {
  final NotificationRepository repository;

  const NotifyAssetAdded(this.repository);

  /// Executes the use case and creates the notification
  ///
  /// [assetType] - The type of asset (e.g., "Insurance", "Vehicle")
  /// [assetName] - The name of the asset
  /// Throws [ValidationException] if parameters are invalid
  /// Throws [StorageException] if the operation fails
  Future<void> call(String assetType, String assetName) async {
    if (assetType.trim().isEmpty) {
      throw const ValidationException('Asset type cannot be empty');
    }
    if (assetName.trim().isEmpty) {
      throw const ValidationException('Asset name cannot be empty');
    }

    try {
      final notification = NotificationEntity(
        id: _generateId(assetName),
        title: 'New Asset Added',
        message: 'Your $assetType "$assetName" has been successfully added.',
        type: NotificationType.assetAdded,
        timestamp: DateTime.now(),
        metadata: {
          'assetType': assetType,
          'assetName': assetName,
        },
      );

      await repository.addNotification(notification);
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to create asset added notification: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Generates a unique ID for the notification
  String _generateId(String assetName) {
    return 'notif_${DateTime.now().millisecondsSinceEpoch}_${assetName.hashCode}';
  }
}

