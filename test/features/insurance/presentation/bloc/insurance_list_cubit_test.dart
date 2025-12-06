import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/features/insurance/domain/entities/insurance.dart';
import 'package:assetwize/features/insurance/domain/usecases/get_insurances.dart';
import 'package:assetwize/features/insurance/presentation/bloc/insurance_list_cubit.dart';
import 'package:assetwize/features/insurance/presentation/bloc/insurance_list_state.dart';

import 'insurance_list_cubit_test.mocks.dart';

@GenerateMocks([GetInsurances])
void main() {
  late InsuranceListCubit cubit;
  late MockGetInsurances mockGetInsurances;

  setUp(() {
    mockGetInsurances = MockGetInsurances();
    cubit = InsuranceListCubit(mockGetInsurances);
  });

  tearDown(() {
    cubit.close();
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

  test('initial state should be InsuranceListInitial', () {
    expect(cubit.state, equals(const InsuranceListInitial()));
  });

  blocTest<InsuranceListCubit, InsuranceListState>(
    'emits [loading, loaded] when loadInsurances succeeds',
    build: () {
      when(mockGetInsurances()).thenAnswer((_) async => tInsurances);
      return cubit;
    },
    act: (cubit) => cubit.loadInsurances(),
    expect: () => [
      const InsuranceListLoading(),
      InsuranceListLoaded(tInsurances),
    ],
    verify: (_) {
      verify(mockGetInsurances()).called(1);
    },
  );

  blocTest<InsuranceListCubit, InsuranceListState>(
    'emits [loading, error] when loadInsurances fails',
    build: () {
      when(mockGetInsurances())
          .thenThrow(Exception('Failed to fetch insurances'));
      return cubit;
    },
    act: (cubit) => cubit.loadInsurances(),
    expect: () => [
      const InsuranceListLoading(),
      const InsuranceListError('Failed to fetch insurances'),
    ],
    verify: (_) {
      verify(mockGetInsurances()).called(1);
    },
  );

  blocTest<InsuranceListCubit, InsuranceListState>(
    'retry calls loadInsurances again',
    build: () {
      when(mockGetInsurances()).thenAnswer((_) async => tInsurances);
      return cubit;
    },
    act: (cubit) => cubit.retry(),
    expect: () => [
      const InsuranceListLoading(),
      InsuranceListLoaded(tInsurances),
    ],
    verify: (_) {
      verify(mockGetInsurances()).called(1);
    },
  );
}
