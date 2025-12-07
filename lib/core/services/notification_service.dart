import 'dart:async';
import '../../features/notifications/domain/entities/notification.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../utils/logger.dart' as logger;

/// Service for managing notifications
///
/// Provides high-level methods to create and manage notifications
/// for various app events like asset added, profile updated, etc.
class NotificationService {
  final NotificationRepository _repository;
  
  // Stream controller for unread count changes
  final _unreadCountController = StreamController<int>.broadcast();
  
  /// Stream that emits unread count whenever it changes
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  NotificationService(this._repository) {
    // Initialize stream with current count
    refreshUnreadCount();
  }

  /// Updates and broadcasts the unread count
  /// Made public so it can be called from other parts of the app
  Future<void> refreshUnreadCount() async {
    try {
      final count = await _repository.getUnreadCount();
      if (!_unreadCountController.isClosed) {
        _unreadCountController.add(count);
      }
    } catch (e) {
      logger.Logger.error('NotificationService: Failed to update unread count', e);
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
  Future<void> notifyAssetAdded(String assetType, String assetName) async {
    try {
      final notification = NotificationEntity(
        id: _generateId(),
        title: 'New Asset Added',
        message: 'Your $assetType "$assetName" has been successfully added.',
        type: NotificationType.assetAdded,
        timestamp: DateTime.now(),
        metadata: {
          'assetType': assetType,
          'assetName': assetName,
        },
      );
      await _repository.addNotification(notification);
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
  Future<void> notifyProfileUpdated(String fieldName) async {
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
      await _repository.addNotification(notification);
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

  /// Creates a notification when insurance is expiring soon
  Future<void> notifyInsuranceExpiring(String insuranceTitle, int daysLeft) async {
    try {
      final notification = NotificationEntity(
        id: _generateId(),
        title: 'Insurance Expiring Soon',
        message: 'Your "$insuranceTitle" insurance expires in $daysLeft days.',
        type: NotificationType.insuranceExpiring,
        timestamp: DateTime.now(),
        metadata: {
          'insuranceTitle': insuranceTitle,
          'daysLeft': daysLeft,
        },
      );
      await _repository.addNotification(notification);
      await refreshUnreadCount(); // Update badge count
      logger.Logger.info('NotificationService: Insurance expiring notification created');
    } catch (e, stackTrace) {
      logger.Logger.error(
        'NotificationService: Failed to create insurance expiring notification',
        e,
        stackTrace,
      );
    }
  }

  /// Creates a notification when insurance has expired
  Future<void> notifyInsuranceExpired(String insuranceTitle) async {
    try {
      final notification = NotificationEntity(
        id: _generateId(),
        title: 'Insurance Expired',
        message: 'Your "$insuranceTitle" insurance has expired. Please renew it.',
        type: NotificationType.insuranceExpired,
        timestamp: DateTime.now(),
        metadata: {
          'insuranceTitle': insuranceTitle,
        },
      );
      await _repository.addNotification(notification);
      await refreshUnreadCount(); // Update badge count
      logger.Logger.info('NotificationService: Insurance expired notification created');
    } catch (e, stackTrace) {
      logger.Logger.error(
        'NotificationService: Failed to create insurance expired notification',
        e,
        stackTrace,
      );
    }
  }

  /// Gets unread notifications count
  Future<int> getUnreadCount() async {
    try {
      return await _repository.getUnreadCount();
    } catch (e) {
      logger.Logger.error('NotificationService: Failed to get unread count', e);
      return 0;
    }
  }

  /// Generates a unique notification ID
  String _generateId() {
    return 'notif_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';
  }
}

