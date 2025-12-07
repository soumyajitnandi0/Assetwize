import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';

/// Local implementation of NotificationRepository
///
/// Uses SharedPreferences for persistent local storage.
class NotificationRepositoryImpl implements NotificationRepository {
  static const String _storageKey = 'notifications';

  /// Loads notifications from SharedPreferences
  Future<List<NotificationModel>> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedJson = prefs.getString(_storageKey);

      if (storedJson == null || storedJson.isEmpty) {
        return [];
      }

      final List<dynamic> storedList = json.decode(storedJson) as List<dynamic>;
      return storedList
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Newest first
    } on FormatException catch (e, stackTrace) {
      throw StorageException(
        'Failed to parse stored notification data',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw StorageException(
        'Failed to load notifications: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Saves notifications to SharedPreferences
  Future<void> _saveNotifications(List<NotificationModel> notifications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = notifications.map((n) => n.toJson()).toList();
      final success = await prefs.setString(_storageKey, json.encode(jsonList));

      if (!success) {
        throw const StorageException('Failed to save notifications to storage');
      }
    } catch (e, stackTrace) {
      if (e is StorageException) {
        rethrow;
      }
      throw StorageException(
        'Failed to save notifications: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    try {
      final notifications = await _loadNotifications();
      return List<NotificationEntity>.from(notifications);
    } catch (e, stackTrace) {
      if (e is StorageException) {
        rethrow;
      }
      throw StorageException(
        'Failed to fetch notifications: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final notifications = await _loadNotifications();
      return notifications.where((n) => !n.isRead).length;
    } catch (e, stackTrace) {
      if (e is StorageException) {
        rethrow;
      }
      throw StorageException(
        'Failed to get unread count: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final notifications = await _loadNotifications();
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index >= 0) {
        notifications[index] = NotificationModel(
          id: notifications[index].id,
          title: notifications[index].title,
          message: notifications[index].message,
          type: notifications[index].type,
          timestamp: notifications[index].timestamp,
          isRead: true,
          metadata: notifications[index].metadata,
        );
        await _saveNotifications(notifications);
      }
    } catch (e, stackTrace) {
      if (e is StorageException) {
        rethrow;
      }
      throw StorageException(
        'Failed to mark notification as read: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final notifications = await _loadNotifications();
      final updatedNotifications = notifications.map((n) {
        if (!n.isRead) {
          return NotificationModel(
            id: n.id,
            title: n.title,
            message: n.message,
            type: n.type,
            timestamp: n.timestamp,
            isRead: true,
            metadata: n.metadata,
          );
        }
        return n;
      }).toList();
      await _saveNotifications(updatedNotifications);
    } catch (e, stackTrace) {
      if (e is StorageException) {
        rethrow;
      }
      throw StorageException(
        'Failed to mark all notifications as read: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> addNotification(NotificationEntity notification) async {
    try {
      final notifications = await _loadNotifications();
      final newNotification = NotificationModel.fromEntity(notification);
      notifications.insert(0, newNotification); // Add at beginning
      await _saveNotifications(notifications);
    } catch (e, stackTrace) {
      if (e is StorageException) {
        rethrow;
      }
      throw StorageException(
        'Failed to add notification: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      final notifications = await _loadNotifications();
      notifications.removeWhere((n) => n.id == notificationId);
      await _saveNotifications(notifications);
    } catch (e, stackTrace) {
      if (e is StorageException) {
        rethrow;
      }
      throw StorageException(
        'Failed to delete notification: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e, stackTrace) {
      throw StorageException(
        'Failed to clear notifications: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

