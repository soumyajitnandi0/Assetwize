import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/features/profile/domain/repositories/profile_repository.dart';
import 'package:assetwize/features/profile/domain/usecases/update_phone_number.dart';
import 'package:assetwize/core/error/exceptions.dart';

import 'update_phone_number_test.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  late UpdatePhoneNumber usecase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    usecase = UpdatePhoneNumber(mockRepository);
  });

  const tPhoneNumber = '+1234567890';

  test('should update phone number through the repository', () async {
    // arrange
    when(mockRepository.updatePhoneNumber(any)).thenAnswer((_) async => {});

    // act
    await usecase(tPhoneNumber);

    // assert
    verify(mockRepository.updatePhoneNumber(tPhoneNumber));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw ValidationException when phone number is empty', () async {
    // act & assert
    expect(() => usecase(''), throwsA(isA<ValidationException>()));
    expect(() => usecase('   '), throwsA(isA<ValidationException>()));
    verifyNever(mockRepository.updatePhoneNumber(any));
  });

  test('should trim whitespace from phone number', () async {
    // arrange
    when(mockRepository.updatePhoneNumber(any)).thenAnswer((_) async => {});

    // act
    await usecase('  +1234567890  ');

    // assert
    verify(mockRepository.updatePhoneNumber('+1234567890'));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw StorageException when repository fails', () async {
    // arrange
    when(mockRepository.updatePhoneNumber(any))
        .thenThrow(const StorageException('Failed to save'));

    // act & assert
    expect(() => usecase(tPhoneNumber), throwsA(isA<StorageException>()));
    verify(mockRepository.updatePhoneNumber(tPhoneNumber));
  });
}

