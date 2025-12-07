import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/features/notifications/domain/entities/notification.dart';
import 'package:assetwize/features/notifications/domain/repositories/notification_repository.dart';
import 'package:assetwize/features/notifications/domain/usecases/notify_asset_added.dart';
import 'package:assetwize/core/error/exceptions.dart';

import 'notify_asset_added_test.mocks.dart';

@GenerateMocks([NotificationRepository])
void main() {
  late NotifyAssetAdded usecase;
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationRepository();
    usecase = NotifyAssetAdded(mockRepository);
  });

  const tAssetType = 'Insurance';
  const tAssetName = 'Home Insurance';

  test('should create and add notification through the repository', () async {
    // arrange
    when(mockRepository.addNotification(any)).thenAnswer((_) async => {});

    // act
    await usecase(tAssetType, tAssetName);

    // assert
    verify(mockRepository.addNotification(any)).called(1);
    final captured = verify(mockRepository.addNotification(captureAny)).captured;
    final notification = captured.first as dynamic;
    expect(notification.title, 'New Asset Added');
    expect(notification.message, contains(tAssetType));
    expect(notification.message, contains(tAssetName));
    expect(notification.type, equals(NotificationType.assetAdded));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw ValidationException when assetType is empty', () async {
    // act & assert
    expect(() => usecase('', tAssetName), throwsA(isA<ValidationException>()));
    expect(() => usecase('   ', tAssetName), throwsA(isA<ValidationException>()));
    verifyNever(mockRepository.addNotification(any));
  });

  test('should throw ValidationException when assetName is empty', () async {
    // act & assert
    expect(() => usecase(tAssetType, ''), throwsA(isA<ValidationException>()));
    expect(() => usecase(tAssetType, '   '), throwsA(isA<ValidationException>()));
    verifyNever(mockRepository.addNotification(any));
  });

  test('should throw StorageException when repository fails', () async {
    // arrange
    when(mockRepository.addNotification(any))
        .thenThrow(StorageException('Failed to save'));

    // act & assert
    expect(() => usecase(tAssetType, tAssetName), throwsA(isA<StorageException>()));
    verify(mockRepository.addNotification(any));
  });
}

