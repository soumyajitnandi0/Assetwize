import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/core/error/exceptions.dart';
import 'package:assetwize/features/garage/domain/entities/garage.dart';
import 'package:assetwize/features/garage/domain/repositories/garage_repository.dart';
import 'package:assetwize/features/garage/domain/usecases/get_garages.dart';

import 'get_garages_test.mocks.dart';

@GenerateMocks([GarageRepository])
void main() {
  late GetGarages usecase;
  late MockGarageRepository mockRepository;

  setUp(() {
    mockRepository = MockGarageRepository();
    usecase = GetGarages(mockRepository);
  });

  const tGarage1 = Garage(
    id: '1',
    vehicleType: 'Car',
    registrationNumber: 'ABC123',
    imageUrl: 'assets/images/car_insurance.png',
  );

  const tGarage2 = Garage(
    id: '2',
    vehicleType: 'Bike',
    registrationNumber: 'XYZ789',
    imageUrl: 'assets/images/bike_insurance.png',
  );

  final tGarages = [tGarage1, tGarage2];

  test('should get list of garages from the repository', () async {
    // arrange
    when(mockRepository.getGarages()).thenAnswer((_) async => tGarages);

    // act
    final result = await usecase();

    // assert
    expect(result, equals(tGarages));
    verify(mockRepository.getGarages());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw StorageException when repository fails', () async {
    // arrange
    when(mockRepository.getGarages())
        .thenThrow(Exception('Failed to fetch'));

    // act & assert
    expect(
      () => usecase(),
      throwsA(isA<StorageException>()),
    );
    verify(mockRepository.getGarages());
  });

  test('should return empty list when no garages exist', () async {
    // arrange
    when(mockRepository.getGarages()).thenAnswer((_) async => []);

    // act
    final result = await usecase();

    // assert
    expect(result, isEmpty);
    verify(mockRepository.getGarages());
  });
}

