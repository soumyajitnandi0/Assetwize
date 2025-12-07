import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/core/error/exceptions.dart';
import 'package:assetwize/features/realty/domain/entities/realty.dart';
import 'package:assetwize/features/realty/domain/repositories/realty_repository.dart';
import 'package:assetwize/features/realty/domain/usecases/get_realty_detail.dart';

import 'get_realty_detail_test.mocks.dart';

@GenerateMocks([RealtyRepository])
void main() {
  late GetRealtyDetail usecase;
  late MockRealtyRepository mockRepository;

  setUp(() {
    mockRepository = MockRealtyRepository();
    usecase = GetRealtyDetail(mockRepository);
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

  const tId = '1';

  test('should get realty detail from the repository', () async {
    // arrange
    when(mockRepository.getRealty(tId)).thenAnswer((_) async => tRealty);

    // act
    final result = await usecase(tId);

    // assert
    expect(result, equals(tRealty));
    verify(mockRepository.getRealty(tId));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw ValidationException when ID is empty', () async {
    // act & assert
    expect(
      () => usecase(''),
      throwsA(isA<ValidationException>()),
    );
    verifyNever(mockRepository.getRealty(any));
  });

  test('should throw StorageException when repository fails', () async {
    // arrange
    when(mockRepository.getRealty(tId))
        .thenThrow(Exception('Realty not found'));

    // act & assert
    expect(
      () => usecase(tId),
      throwsA(isA<StorageException>()),
    );
    verify(mockRepository.getRealty(tId));
  });
}

