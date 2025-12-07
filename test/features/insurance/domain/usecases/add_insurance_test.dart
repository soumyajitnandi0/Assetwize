import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/core/error/exceptions.dart';
import 'package:assetwize/features/insurance/domain/entities/insurance.dart';
import 'package:assetwize/features/insurance/domain/repositories/insurance_repository.dart';
import 'package:assetwize/features/insurance/domain/usecases/add_insurance.dart';

import 'add_insurance_test.mocks.dart';

@GenerateMocks([InsuranceRepository])
void main() {
  late AddInsurance usecase;
  late MockInsuranceRepository mockRepository;

  setUp(() {
    mockRepository = MockInsuranceRepository();
    usecase = AddInsurance(mockRepository);
  });

  final tInsurance = Insurance(
    id: '1',
    title: 'Home Insurance',
    provider: 'ICICI',
    policyNumber: '4395654698345',
    startDate: DateTime(2024, 1, 15),
    endDate: DateTime(2025, 9, 2),
    imageUrl: 'https://example.com/image1.jpg',
    type: 'Home Insurance',
  );

  test('should add insurance successfully', () async {
    // arrange
    when(mockRepository.addInsurance(tInsurance)).thenAnswer((_) async => {});

    // act
    await usecase(tInsurance);

    // assert
    verify(mockRepository.addInsurance(tInsurance));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw ValidationException when ID is empty', () async {
    // arrange
    final invalidInsurance = Insurance(
      id: '',
      title: 'Home Insurance',
      provider: 'ICICI',
      policyNumber: '4395654698345',
      startDate: DateTime(2024, 1, 15),
      endDate: DateTime(2025, 9, 2),
      imageUrl: 'https://example.com/image1.jpg',
      type: 'Home Insurance',
    );

    // act & assert
    expect(
      () => usecase(invalidInsurance),
      throwsA(isA<ValidationException>()),
    );
    verifyNever(mockRepository.addInsurance(any));
  });

  test('should throw ValidationException when title is empty', () async {
    // arrange
    final invalidInsurance = Insurance(
      id: '1',
      title: '   ',
      provider: 'ICICI',
      policyNumber: '4395654698345',
      startDate: DateTime(2024, 1, 15),
      endDate: DateTime(2025, 9, 2),
      imageUrl: 'https://example.com/image1.jpg',
      type: 'Home Insurance',
    );

    // act & assert
    expect(
      () => usecase(invalidInsurance),
      throwsA(isA<ValidationException>()),
    );
    verifyNever(mockRepository.addInsurance(any));
  });

  test('should throw ValidationException when end date is before start date', () async {
    // arrange
    final invalidInsurance = Insurance(
      id: '1',
      title: 'Home Insurance',
      provider: 'ICICI',
      policyNumber: '4395654698345',
      startDate: DateTime(2025, 1, 15),
      endDate: DateTime(2024, 9, 2),
      imageUrl: 'https://example.com/image1.jpg',
      type: 'Home Insurance',
    );

    // act & assert
    expect(
      () => usecase(invalidInsurance),
      throwsA(isA<ValidationException>()),
    );
    verifyNever(mockRepository.addInsurance(any));
  });

  test('should throw StorageException when repository fails', () async {
    // arrange
    when(mockRepository.addInsurance(tInsurance))
        .thenThrow(Exception('Storage error'));

    // act & assert
    expect(
      () => usecase(tInsurance),
      throwsA(isA<StorageException>()),
    );
    verify(mockRepository.addInsurance(tInsurance));
  });
}

