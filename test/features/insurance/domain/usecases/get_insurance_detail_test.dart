import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/features/insurance/domain/entities/insurance.dart';
import 'package:assetwize/features/insurance/domain/repositories/insurance_repository.dart';
import 'package:assetwize/features/insurance/domain/usecases/get_insurance_detail.dart';

import 'get_insurance_detail_test.mocks.dart';

@GenerateMocks([InsuranceRepository])
void main() {
  late GetInsuranceDetail usecase;
  late MockInsuranceRepository mockRepository;

  setUp(() {
    mockRepository = MockInsuranceRepository();
    usecase = GetInsuranceDetail(mockRepository);
  });

  var tInsurance = Insurance(
    id: '1',
    title: 'Home Insurance',
    provider: 'ICICI',
    policyNumber: '4395654698345',
    startDate: DateTime(2024, 1, 15),
    endDate: DateTime(2025, 9, 2),
    imageUrl: 'https://example.com/image1.jpg',
    type: 'Home Insurance',
  );

  const tId = '1';

  test('should get insurance detail from the repository', () async {
    // arrange
    when(mockRepository.getInsurance(tId)).thenAnswer((_) async => tInsurance);

    // act
    final result = await usecase(tId);

    // assert
    expect(result, equals(tInsurance));
    verify(mockRepository.getInsurance(tId));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw exception when insurance not found', () async {
    // arrange
    when(mockRepository.getInsurance(tId))
        .thenThrow(Exception('Insurance not found'));

    // act & assert
    expect(() => usecase(tId), throwsException);
    verify(mockRepository.getInsurance(tId));
  });
}
