import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/core/error/exceptions.dart';
import 'package:assetwize/features/realty/domain/entities/realty.dart';
import 'package:assetwize/features/realty/domain/repositories/realty_repository.dart';
import 'package:assetwize/features/realty/domain/usecases/get_realties.dart';

import 'get_realties_test.mocks.dart';

@GenerateMocks([RealtyRepository])
void main() {
  late GetRealties usecase;
  late MockRealtyRepository mockRepository;

  setUp(() {
    mockRepository = MockRealtyRepository();
    usecase = GetRealties(mockRepository);
  });

  const tRealty1 = Realty(
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

  const tRealty2 = Realty(
    id: '2',
    propertyType: 'Apartment',
    address: '456 Park Ave',
    city: 'Delhi',
    state: 'Delhi',
    country: 'India',
    area: 1200.0,
    areaUnit: 'sqft',
    imageUrl: 'assets/images/apartment.png',
  );

  final tRealties = [tRealty1, tRealty2];

  test('should get list of realty items from the repository', () async {
    // arrange
    when(mockRepository.getRealties()).thenAnswer((_) async => tRealties);

    // act
    final result = await usecase();

    // assert
    expect(result, equals(tRealties));
    verify(mockRepository.getRealties());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw StorageException when repository fails', () async {
    // arrange
    when(mockRepository.getRealties())
        .thenThrow(Exception('Failed to fetch'));

    // act & assert
    expect(
      () => usecase(),
      throwsA(isA<StorageException>()),
    );
    verify(mockRepository.getRealties());
  });

  test('should return empty list when no realty items exist', () async {
    // arrange
    when(mockRepository.getRealties()).thenAnswer((_) async => []);

    // act
    final result = await usecase();

    // assert
    expect(result, isEmpty);
    verify(mockRepository.getRealties());
  });
}

