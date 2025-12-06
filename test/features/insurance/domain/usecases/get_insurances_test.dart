import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/features/insurance/domain/entities/insurance.dart';
import 'package:assetwize/features/insurance/domain/repositories/insurance_repository.dart';
import 'package:assetwize/features/insurance/domain/usecases/get_insurances.dart';

import 'get_insurances_test.mocks.dart';

@GenerateMocks([InsuranceRepository])
void main() {
  late GetInsurances usecase;
  late MockInsuranceRepository mockRepository;

  setUp(() {
    mockRepository = MockInsuranceRepository();
    usecase = GetInsurances(mockRepository);
  });

  final tInsurance1 = Insurance(
    id: '1',
    title: 'Home Insurance',
    provider: 'ICICI',
    policyNumber: '4395654698345',
    startDate: DateTime(2024, 1, 15),
    endDate: DateTime(2025, 9, 2),
    imageUrl: 'https://example.com/image1.jpg',
    type: 'Home Insurance',
  );

  final tInsurance2 = Insurance(
    id: '2',
    title: 'Life Insurance',
    provider: 'ICICI',
    policyNumber: '4395654698346',
    startDate: DateTime(2023, 6, 10),
    endDate: DateTime(2025, 9, 2),
    imageUrl: 'https://example.com/image2.jpg',
    type: 'Life Insurance',
  );

  final tInsurances = [tInsurance1, tInsurance2];

  test('should get list of insurances from the repository', () async {
    // arrange
    when(mockRepository.getInsurances()).thenAnswer((_) async => tInsurances);

    // act
    final result = await usecase();

    // assert
    expect(result, equals(tInsurances));
    verify(mockRepository.getInsurances());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw exception when repository fails', () async {
    // arrange
    when(mockRepository.getInsurances())
        .thenThrow(Exception('Failed to fetch'));

    // act & assert
    expect(() => usecase(), throwsException);
    verify(mockRepository.getInsurances());
  });
}
