import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/core/error/exceptions.dart';
import 'package:assetwize/features/garage/domain/entities/garage.dart';
import 'package:assetwize/features/garage/domain/repositories/garage_repository.dart';
import 'package:assetwize/features/garage/domain/usecases/add_garage.dart';

import 'add_garage_test.mocks.dart';

@GenerateMocks([GarageRepository])
void main() {
  late AddGarage usecase;
  late MockGarageRepository mockRepository;

  setUp(() {
    mockRepository = MockGarageRepository();
    usecase = AddGarage(mockRepository);
  });

  const tGarage = Garage(
    id: '1',
    vehicleType: 'Car',
    registrationNumber: 'ABC123',
    imageUrl: 'assets/images/car_insurance.png',
  );

  test('should add garage successfully', () async {
    // arrange
    when(mockRepository.addGarage(tGarage)).thenAnswer((_) async => {});

    // act
    await usecase(tGarage);

    // assert
    verify(mockRepository.addGarage(tGarage));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw ValidationException when vehicle type is empty', () async {
    // arrange
    const invalidGarage = Garage(
      id: '1',
      vehicleType: '',
      registrationNumber: 'ABC123',
      imageUrl: 'assets/images/car_insurance.png',
    );

    // act & assert
    expect(
      () => usecase(invalidGarage),
      throwsA(isA<ValidationException>()),
    );
    verifyNever(mockRepository.addGarage(any));
  });

  test('should throw ValidationException when registration number is empty', () async {
    // arrange
    const invalidGarage = Garage(
      id: '1',
      vehicleType: 'Car',
      registrationNumber: '',
      imageUrl: 'assets/images/car_insurance.png',
    );

    // act & assert
    expect(
      () => usecase(invalidGarage),
      throwsA(isA<ValidationException>()),
    );
    verifyNever(mockRepository.addGarage(any));
  });

  test('should throw StorageException when repository fails', () async {
    // arrange
    when(mockRepository.addGarage(tGarage))
        .thenThrow(Exception('Storage error'));

    // act & assert
    expect(
      () => usecase(tGarage),
      throwsA(isA<StorageException>()),
    );
    verify(mockRepository.addGarage(tGarage));
  });
}

