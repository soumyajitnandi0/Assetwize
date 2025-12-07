import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/core/error/exceptions.dart';
import 'package:assetwize/features/realty/domain/entities/realty.dart';
import 'package:assetwize/features/realty/domain/repositories/realty_repository.dart';
import 'package:assetwize/features/realty/domain/usecases/add_realty.dart';

import 'add_realty_test.mocks.dart';

@GenerateMocks([RealtyRepository])
void main() {
  late AddRealty usecase;
  late MockRealtyRepository mockRepository;

  setUp(() {
    mockRepository = MockRealtyRepository();
    usecase = AddRealty(mockRepository);
  });

  const tRealty = Realty(
    id: '1',
    propertyType: 'House',
    address: '123 Main St',
    city: 'Mumbai',
    state: 'Maharashtra',
    country: 'India',
    area: 1500.0,
    areaUnit: 'sqft',
    imageUrl: 'assets/images/house.png',
  );

  test('should add realty successfully', () async {
    // arrange
    when(mockRepository.addRealty(tRealty)).thenAnswer((_) async => {});

    // act
    await usecase(tRealty);

    // assert
    verify(mockRepository.addRealty(tRealty));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw ValidationException when property type is empty', () async {
    // arrange
    const invalidRealty = Realty(
      id: '1',
      propertyType: '   ',
      address: '123 Main St',
      city: 'Mumbai',
      state: 'Maharashtra',
      country: 'India',
      area: 1500.0,
      areaUnit: 'sqft',
      imageUrl: 'assets/images/house.png',
    );

    // act & assert
    expect(
      () => usecase(invalidRealty),
      throwsA(isA<ValidationException>()),
    );
    verifyNever(mockRepository.addRealty(any));
  });

  test('should throw ValidationException when address is empty', () async {
    // arrange
    const invalidRealty = Realty(
      id: '1',
      propertyType: 'House',
      address: '   ',
      city: 'Mumbai',
      state: 'Maharashtra',
      country: 'India',
      area: 1500.0,
      areaUnit: 'sqft',
      imageUrl: 'assets/images/house.png',
    );

    // act & assert
    expect(
      () => usecase(invalidRealty),
      throwsA(isA<ValidationException>()),
    );
    verifyNever(mockRepository.addRealty(any));
  });

  test('should throw StorageException when repository fails', () async {
    // arrange
    when(mockRepository.addRealty(tRealty))
        .thenThrow(Exception('Storage error'));

    // act & assert
    expect(
      () => usecase(tRealty),
      throwsA(isA<StorageException>()),
    );
    verify(mockRepository.addRealty(tRealty));
  });
}

