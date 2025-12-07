import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/features/profile/domain/repositories/profile_repository.dart';
import 'package:assetwize/features/profile/domain/usecases/update_name.dart';
import 'package:assetwize/core/error/exceptions.dart';

import 'update_name_test.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  late UpdateName usecase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    usecase = UpdateName(mockRepository);
  });

  const tName = 'John Doe';

  test('should update name through the repository', () async {
    // arrange
    when(mockRepository.updateName(any)).thenAnswer((_) async => {});

    // act
    await usecase(tName);

    // assert
    verify(mockRepository.updateName(tName));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw ValidationException when name is empty', () async {
    // act & assert
    expect(() => usecase(''), throwsA(isA<ValidationException>()));
    expect(() => usecase('   '), throwsA(isA<ValidationException>()));
    verifyNever(mockRepository.updateName(any));
  });

  test('should trim whitespace from name', () async {
    // arrange
    when(mockRepository.updateName(any)).thenAnswer((_) async => {});

    // act
    await usecase('  John Doe  ');

    // assert
    verify(mockRepository.updateName('John Doe'));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw StorageException when repository fails', () async {
    // arrange
    when(mockRepository.updateName(any))
        .thenThrow(StorageException('Failed to save'));

    // act & assert
    expect(() => usecase(tName), throwsA(isA<StorageException>()));
    verify(mockRepository.updateName(tName));
  });
}

