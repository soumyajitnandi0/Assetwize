import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/mark_notification_as_read.dart';
import '../../domain/usecases/mark_all_as_read.dart';
import '../../domain/usecases/delete_notification.dart';
import 'notifications_state.dart';

/// Cubit for managing notifications state
class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotifications _getNotifications;
  final MarkNotificationAsRead _markNotificationAsRead;
  final MarkAllAsRead _markAllAsRead;
  final DeleteNotification _deleteNotification;

  NotificationsCubit(
    this._getNotifications,
    this._markNotificationAsRead,
    this._markAllAsRead,
    this._deleteNotification,
  ) : super(const NotificationsInitial());

  /// Loads all notifications
  Future<void> loadNotifications() async {
    emit(const NotificationsLoading());
    logger.Logger.debug('NotificationsCubit: Loading notifications...');

    try {
      final notifications = await _getNotifications();
      emit(NotificationsLoaded(notifications: notifications));
      logger.Logger.info(
          'NotificationsCubit: Successfully loaded ${notifications.length} notifications');
    } catch (e, stackTrace) {
      final errorMessage = _extractErrorMessage(e);
      emit(NotificationsError(errorMessage));
      logger.Logger.error(
        'NotificationsCubit: Failed to load notifications',
        e,
        stackTrace,
      );
    }
  }

  /// Marks a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _markNotificationAsRead(notificationId);
      await loadNotifications(); // Reload to update state
      // Trigger unread count update
      sl<NotificationService>().refreshUnreadCount();
      logger.Logger.info('NotificationsCubit: Marked notification as read');
    } catch (e, stackTrace) {
      logger.Logger.error(
        'NotificationsCubit: Failed to mark notification as read',
        e,
        stackTrace,
      );
    }
  }

  /// Marks all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _markAllAsRead();
      await loadNotifications(); // Reload to update state
      // Trigger unread count update
      sl<NotificationService>().refreshUnreadCount();
      logger.Logger.info('NotificationsCubit: Marked all notifications as read');
    } catch (e, stackTrace) {
      logger.Logger.error(
        'NotificationsCubit: Failed to mark all notifications as read',
        e,
        stackTrace,
      );
    }
  }

  /// Deletes a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _deleteNotification(notificationId);
      await loadNotifications(); // Reload to update state
      // Trigger unread count update
      sl<NotificationService>().refreshUnreadCount();
      logger.Logger.info('NotificationsCubit: Deleted notification');
    } catch (e, stackTrace) {
      logger.Logger.error(
        'NotificationsCubit: Failed to delete notification',
        e,
        stackTrace,
      );
    }
  }

  /// Extracts a user-friendly error message from an exception
  String _extractErrorMessage(Object error) {
    final errorString = error.toString();
    if (errorString.startsWith('Exception: ')) {
      return errorString.substring(11);
    }
    if (errorString.isEmpty) {
      return 'Failed to load notifications. Please try again.';
    }
    return errorString;
  }
}

