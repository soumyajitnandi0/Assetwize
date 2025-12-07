import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/features/notifications/domain/entities/notification.dart';
import 'package:assetwize/features/notifications/domain/repositories/notification_repository.dart';
import 'package:assetwize/features/notifications/domain/usecases/get_notifications.dart';
import 'package:assetwize/core/error/exceptions.dart';

import 'get_notifications_test.mocks.dart';

@GenerateMocks([NotificationRepository])
void main() {
  late GetNotifications usecase;
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationRepository();
    usecase = GetNotifications(mockRepository);
  });

  final tNotification1 = NotificationEntity(
    id: '1',
    title: 'Test Notification',
    message: 'Test message',
    type: NotificationType.assetAdded,
    timestamp: DateTime.now(),
  );

  final tNotification2 = NotificationEntity(
    id: '2',
    title: 'Test Notification 2',
    message: 'Test message 2',
    type: NotificationType.profileUpdated,
    timestamp: DateTime.now(),
  );

  final tNotifications = [tNotification1, tNotification2];

  test('should get list of notifications from the repository', () async {
    // arrange
    when(mockRepository.getNotifications()).thenAnswer((_) async => tNotifications);

    // act
    final result = await usecase();

    // assert
    expect(result, equals(tNotifications));
    verify(mockRepository.getNotifications());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw StorageException when repository fails', () async {
    // arrange
    when(mockRepository.getNotifications())
        .thenThrow(StorageException('Failed to fetch'));

    // act & assert
    expect(() => usecase(), throwsA(isA<StorageException>()));
    verify(mockRepository.getNotifications());
  });
}

