import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/features/insurance/domain/entities/insurance.dart';
import 'package:assetwize/features/insurance/domain/usecases/get_insurance_detail.dart';
import 'package:assetwize/features/insurance/presentation/bloc/insurance_detail_cubit.dart';
import 'package:assetwize/features/insurance/presentation/bloc/insurance_detail_state.dart';

import 'insurance_detail_cubit_test.mocks.dart';

@GenerateMocks([GetInsuranceDetail])
void main() {
  late InsuranceDetailCubit cubit;
  late MockGetInsuranceDetail mockGetInsuranceDetail;

  setUp(() {
    mockGetInsuranceDetail = MockGetInsuranceDetail();
    cubit = InsuranceDetailCubit(mockGetInsuranceDetail);
  });

  tearDown(() {
    cubit.close();
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

  const tId = '1';

  test('initial state should be InsuranceDetailInitial', () {
    expect(cubit.state, equals(const InsuranceDetailInitial()));
  });

  blocTest<InsuranceDetailCubit, InsuranceDetailState>(
    'emits [loading, loaded] when loadInsurance succeeds',
    build: () {
      when(mockGetInsuranceDetail(tId)).thenAnswer((_) async => tInsurance);
      return cubit;
    },
    act: (cubit) => cubit.loadInsurance(tId),
    expect: () => [
      const InsuranceDetailLoading(),
      InsuranceDetailLoaded(tInsurance),
    ],
    verify: (_) {
      verify(mockGetInsuranceDetail(tId)).called(1);
    },
  );

  blocTest<InsuranceDetailCubit, InsuranceDetailState>(
    'emits [loading, error] when loadInsurance fails',
    build: () {
      when(mockGetInsuranceDetail(tId))
          .thenThrow(Exception('Insurance not found'));
      return cubit;
    },
    act: (cubit) => cubit.loadInsurance(tId),
    expect: () => [
      const InsuranceDetailLoading(),
      const InsuranceDetailError('Insurance not found'),
    ],
    verify: (_) {
      verify(mockGetInsuranceDetail(tId)).called(1);
    },
  );

  blocTest<InsuranceDetailCubit, InsuranceDetailState>(
    'retry calls loadInsurance again',
    build: () {
      when(mockGetInsuranceDetail(tId)).thenAnswer((_) async => tInsurance);
      return cubit;
    },
    act: (cubit) => cubit.retry(tId),
    expect: () => [
      const InsuranceDetailLoading(),
      InsuranceDetailLoaded(tInsurance),
    ],
    verify: (_) {
      verify(mockGetInsuranceDetail(tId)).called(1);
    },
  );
}
