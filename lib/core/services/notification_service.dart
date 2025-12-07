import 'dart:async';
import '../../features/notifications/domain/usecases/get_unread_count.dart';
import '../../features/notifications/domain/usecases/notify_asset_added.dart';
import '../../features/notifications/domain/usecases/notify_profile_updated.dart';
import '../utils/logger.dart' as logger;

/// Service for managing notification streams and coordination
///
/// This service acts as an infrastructure layer that coordinates
/// notification use cases and provides a stream for unread count updates.
/// Business logic is handled by domain use cases.
class NotificationService {
  final GetUnreadCount _getUnreadCount;
  final NotifyAssetAdded _notifyAssetAdded;
  final NotifyProfileUpdated _notifyProfileUpdated;
  
  // Stream controller for unread count changes
  final _unreadCountController = StreamController<int>.broadcast();
  
  /// Stream that emits unread count whenever it changes
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  NotificationService(
    this._getUnreadCount,
    this._notifyAssetAdded,
    this._notifyProfileUpdated,
  ) {
    // Initialize stream with current count
    refreshUnreadCount();
  }

  /// Updates and broadcasts the unread count
  /// Made public so it can be called from other parts of the app
  Future<void> refreshUnreadCount() async {
    try {
      final count = await _getUnreadCount();
      if (!_unreadCountController.isClosed) {
        _unreadCountController.add(count);
      }
    } catch (e, stackTrace) {
      logger.Logger.error(
        'NotificationService: Failed to update unread count',
        e,
        stackTrace,
      );
      if (!_unreadCountController.isClosed) {
        _unreadCountController.add(0);
      }
    }
  }

  /// Disposes the stream controller
  void dispose() {
    _unreadCountController.close();
  }

  /// Creates a notification when a new asset is added
  /// Uses the domain use case for business logic
  Future<void> notifyAssetAdded(String assetType, String assetName) async {
    try {
      await _notifyAssetAdded(assetType, assetName);
      await refreshUnreadCount(); // Update badge count
      logger.Logger.info('NotificationService: Asset added notification created');
    } catch (e, stackTrace) {
      logger.Logger.error(
        'NotificationService: Failed to create asset added notification',
        e,
        stackTrace,
      );
    }
  }

  /// Creates a notification when profile details are updated
  /// Uses the domain use case for business logic
  Future<void> notifyProfileUpdated(String fieldName) async {
    try {
      await _notifyProfileUpdated(fieldName);
      await refreshUnreadCount(); // Update badge count
      logger.Logger.info('NotificationService: Profile updated notification created');
    } catch (e, stackTrace) {
      logger.Logger.error(
        'NotificationService: Failed to create profile updated notification',
        e,
        stackTrace,
      );
    }
  }

  /// Gets unread notifications count
  /// Uses the domain use case for business logic
  Future<int> getUnreadCount() async {
    try {
      return await _getUnreadCount();
    } catch (e, stackTrace) {
      logger.Logger.error(
        'NotificationService: Failed to get unread count',
        e,
        stackTrace,
      );
      return 0;
    }
  }
}

