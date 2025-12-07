import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:assetwize/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:assetwize/features/notifications/domain/entities/notification.dart';
import 'package:assetwize/core/error/exceptions.dart';

void main() {
  late NotificationRepositoryImpl repository;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = NotificationRepositoryImpl();
  });

  tearDown(() async {
    await prefs.clear();
  });

  final tNotification1 = NotificationEntity(
    id: '1',
    title: 'New Asset Added',
    message: 'Your Insurance "Home Insurance" has been added.',
    type: NotificationType.assetAdded,
    timestamp: DateTime(2024, 1, 1),
    isRead: false,
  );

  final tNotification2 = NotificationEntity(
    id: '2',
    title: 'Profile Updated',
    message: 'Your profile has been updated.',
    type: NotificationType.profileUpdated,
    timestamp: DateTime(2024, 1, 2),
    isRead: true,
  );

  final tNotification3 = NotificationEntity(
    id: '3',
    title: 'Insurance Expiring',
    message: 'Your insurance is expiring soon.',
    type: NotificationType.insuranceExpiring,
    timestamp: DateTime(2024, 1, 3),
    isRead: false,
  );

  group('getNotifications', () {
    test('should return empty list when no data is stored', () async {
      // act
      final result = await repository.getNotifications();

      // assert
      expect(result, isEmpty);
    });

    test('should return list of notifications when data exists', () async {
      // arrange
      await repository.addNotification(tNotification1);

      // act
      final result = await repository.getNotifications();

      // assert
      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.title, 'New Asset Added');
    });

    test('should return notifications sorted by timestamp (newest first)', () async {
      // arrange
      await repository.addNotification(tNotification1);
      await repository.addNotification(tNotification2);
      await repository.addNotification(tNotification3);

      // act
      final result = await repository.getNotifications();

      // assert
      expect(result.length, 3);
      // Should be sorted newest first
      expect(result.first.id, '3');
      expect(result.last.id, '1');
    });

    test('should throw StorageException when data is corrupted', () async {
      // arrange
      await prefs.setString('notifications', 'invalid json');

      // act & assert
      expect(
        () => repository.getNotifications(),
        throwsA(isA<StorageException>()),
      );
    });
  });

  group('getUnreadCount', () {
    test('should return 0 when no notifications exist', () async {
      // act
      final result = await repository.getUnreadCount();

      // assert
      expect(result, 0);
    });

    test('should return correct unread count', () async {
      // arrange
      await repository.addNotification(tNotification1); // unread
      await repository.addNotification(tNotification2); // read
      await repository.addNotification(tNotification3); // unread

      // act
      final result = await repository.getUnreadCount();

      // assert
      expect(result, 2);
    });

    test('should return 0 when all notifications are read', () async {
      // arrange
      await repository.addNotification(tNotification2); // read
      await repository.markAllAsRead();

      // act
      final result = await repository.getUnreadCount();

      // assert
      expect(result, 0);
    });
  });

  group('markAsRead', () {
    test('should mark notification as read', () async {
      // arrange
      await repository.addNotification(tNotification1);

      // act
      await repository.markAsRead('1');

      // assert
      final notifications = await repository.getNotifications();
      expect(notifications.first.isRead, isTrue);
      expect(await repository.getUnreadCount(), 0);
    });

    test('should not throw when marking non-existent notification', () async {
      // act - should not throw
      await repository.markAsRead('999');

      // assert - no error thrown
      expect(true, isTrue);
    });
  });

  group('markAllAsRead', () {
    test('should mark all notifications as read', () async {
      // arrange
      await repository.addNotification(tNotification1); // unread
      await repository.addNotification(tNotification3); // unread

      // act
      await repository.markAllAsRead();

      // assert
      final notifications = await repository.getNotifications();
      expect(notifications.every((n) => n.isRead), isTrue);
      expect(await repository.getUnreadCount(), 0);
    });

    test('should not affect already read notifications', () async {
      // arrange
      await repository.addNotification(tNotification2); // already read

      // act
      await repository.markAllAsRead();

      // assert
      final notifications = await repository.getNotifications();
      expect(notifications.first.isRead, isTrue);
    });
  });

  group('addNotification', () {
    test('should add new notification successfully', () async {
      // act
      await repository.addNotification(tNotification1);

      // assert
      final notifications = await repository.getNotifications();
      expect(notifications.length, 1);
      expect(notifications.first.id, '1');
    });

    test('should add notification at the beginning of list', () async {
      // arrange
      await repository.addNotification(tNotification1);

      // act
      await repository.addNotification(tNotification2);

      // assert
      final notifications = await repository.getNotifications();
      expect(notifications.length, 2);
      expect(notifications.first.id, '2'); // Newest first
    });

    test('should add multiple notifications', () async {
      // act
      await repository.addNotification(tNotification1);
      await repository.addNotification(tNotification2);
      await repository.addNotification(tNotification3);

      // assert
      final notifications = await repository.getNotifications();
      expect(notifications.length, 3);
    });
  });

  group('deleteNotification', () {
    test('should delete notification successfully', () async {
      // arrange
      await repository.addNotification(tNotification1);
      await repository.addNotification(tNotification2);

      // act
      await repository.deleteNotification('1');

      // assert
      final notifications = await repository.getNotifications();
      expect(notifications.length, 1);
      expect(notifications.first.id, '2');
    });

    test('should not throw when deleting non-existent notification', () async {
      // act - should not throw
      await repository.deleteNotification('999');

      // assert - no error thrown
      expect(true, isTrue);
    });
  });

  group('clearAll', () {
    test('should clear all notifications', () async {
      // arrange
      await repository.addNotification(tNotification1);
      await repository.addNotification(tNotification2);
      await repository.addNotification(tNotification3);

      // act
      await repository.clearAll();

      // assert
      final notifications = await repository.getNotifications();
      expect(notifications, isEmpty);
      expect(await repository.getUnreadCount(), 0);
    });
  });
}

