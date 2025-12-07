import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/features/profile/domain/repositories/profile_repository.dart';
import 'package:assetwize/features/profile/domain/usecases/update_email.dart';
import 'package:assetwize/core/error/exceptions.dart';

import 'update_email_test.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  late UpdateEmail usecase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    usecase = UpdateEmail(mockRepository);
  });

  const tEmail = 'john@example.com';

  test('should update email through the repository', () async {
    // arrange
    when(mockRepository.updateEmail(any)).thenAnswer((_) async => {});

    // act
    await usecase(tEmail);

    // assert
    verify(mockRepository.updateEmail(tEmail));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw ValidationException when email is empty', () async {
    // act & assert
    expect(() => usecase(''), throwsA(isA<ValidationException>()));
    expect(() => usecase('   '), throwsA(isA<ValidationException>()));
    verifyNever(mockRepository.updateEmail(any));
  });

  test('should trim whitespace from email', () async {
    // arrange
    when(mockRepository.updateEmail(any)).thenAnswer((_) async => {});

    // act
    await usecase('  john@example.com  ');

    // assert
    verify(mockRepository.updateEmail('john@example.com'));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw StorageException when repository fails', () async {
    // arrange
    when(mockRepository.updateEmail(any))
        .thenThrow(const StorageException('Failed to save'));

    // act & assert
    expect(() => usecase(tEmail), throwsA(isA<StorageException>()));
    verify(mockRepository.updateEmail(tEmail));
  });
}

