import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:assetwize/features/onboarding/domain/usecases/check_first_launch.dart';
import 'package:assetwize/core/error/exceptions.dart';

import 'check_first_launch_test.mocks.dart';

@GenerateMocks([OnboardingRepository])
void main() {
  late CheckFirstLaunch usecase;
  late MockOnboardingRepository mockRepository;

  setUp(() {
    mockRepository = MockOnboardingRepository();
    usecase = CheckFirstLaunch(mockRepository);
  });

  test('should return true when it is first launch', () async {
    // arrange
    when(mockRepository.isFirstLaunch()).thenAnswer((_) async => true);

    // act
    final result = await usecase();

    // assert
    expect(result, isTrue);
    verify(mockRepository.isFirstLaunch());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return false when it is not first launch', () async {
    // arrange
    when(mockRepository.isFirstLaunch()).thenAnswer((_) async => false);

    // act
    final result = await usecase();

    // assert
    expect(result, isFalse);
    verify(mockRepository.isFirstLaunch());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw StorageException when repository fails', () async {
    // arrange
    when(mockRepository.isFirstLaunch())
        .thenThrow(StorageException('Failed to check'));

    // act & assert
    expect(() => usecase(), throwsA(isA<StorageException>()));
    verify(mockRepository.isFirstLaunch());
  });
}

