import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/features/profile/domain/entities/user_profile.dart';
import 'package:assetwize/features/profile/domain/repositories/profile_repository.dart';
import 'package:assetwize/features/profile/domain/usecases/get_profile.dart';
import 'package:assetwize/core/error/exceptions.dart';

import 'get_profile_test.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  late GetProfile usecase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    usecase = GetProfile(mockRepository);
  });

  final tProfile = const UserProfile(
    name: 'John Doe',
    phoneNumber: '+1234567890',
    email: 'john@example.com',
  );

  test('should get profile from the repository', () async {
    // arrange
    when(mockRepository.getProfile()).thenAnswer((_) async => tProfile);

    // act
    final result = await usecase();

    // assert
    expect(result, equals(tProfile));
    verify(mockRepository.getProfile());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw StorageException when repository fails', () async {
    // arrange
    when(mockRepository.getProfile())
        .thenThrow(StorageException('Failed to fetch'));

    // act & assert
    expect(() => usecase(), throwsA(isA<StorageException>()));
    verify(mockRepository.getProfile());
  });

  test('should wrap non-AppException in StorageException', () async {
    // arrange
    when(mockRepository.getProfile())
        .thenThrow(Exception('Network error'));

    // act & assert
    expect(() => usecase(), throwsA(isA<StorageException>()));
    verify(mockRepository.getProfile());
  });
}

