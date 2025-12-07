import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/core/error/exceptions.dart';
import 'package:assetwize/features/garage/domain/entities/garage.dart';
import 'package:assetwize/features/garage/domain/repositories/garage_repository.dart';
import 'package:assetwize/features/garage/domain/usecases/get_garage_detail.dart';

import 'get_garage_detail_test.mocks.dart';

@GenerateMocks([GarageRepository])
void main() {
  late GetGarageDetail usecase;
  late MockGarageRepository mockRepository;

  setUp(() {
    mockRepository = MockGarageRepository();
    usecase = GetGarageDetail(mockRepository);
  });

  const tGarage = Garage(
    id: '1',
    vehicleType: 'Car',
    registrationNumber: 'ABC123',
    imageUrl: 'assets/images/car_insurance.png',
  );

  const tId = '1';

  test('should get garage detail from the repository', () async {
    // arrange
    when(mockRepository.getGarage(tId)).thenAnswer((_) async => tGarage);

    // act
    final result = await usecase(tId);

    // assert
    expect(result, equals(tGarage));
    verify(mockRepository.getGarage(tId));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw ValidationException when ID is empty', () async {
    // act & assert
    expect(
      () => usecase(''),
      throwsA(isA<ValidationException>()),
    );
    verifyNever(mockRepository.getGarage(any));
  });

  test('should throw StorageException when repository fails', () async {
    // arrange
    when(mockRepository.getGarage(tId))
        .thenThrow(Exception('Garage not found'));

    // act & assert
    expect(
      () => usecase(tId),
      throwsA(isA<StorageException>()),
    );
    verify(mockRepository.getGarage(tId));
  });
}

