import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/features/garage/domain/entities/garage.dart';
import 'package:assetwize/features/garage/domain/usecases/get_garage_detail.dart';
import 'package:assetwize/features/garage/presentation/bloc/garage_detail_cubit.dart';
import 'package:assetwize/features/garage/presentation/bloc/garage_detail_state.dart';

import 'garage_detail_cubit_test.mocks.dart';

@GenerateMocks([GetGarageDetail])
void main() {
  late GarageDetailCubit cubit;
  late MockGetGarageDetail mockGetGarageDetail;

  setUp(() {
    mockGetGarageDetail = MockGetGarageDetail();
    cubit = GarageDetailCubit(mockGetGarageDetail);
  });

  tearDown(() {
    cubit.close();
  });

  const tGarageId = '1';
  final tGarage = Garage(
    id: tGarageId,
    vehicleType: 'Car',
    registrationNumber: 'ABC123',
    imageUrl: 'assets/images/car_insurance.png',
  );

  test('initial state should be GarageDetailInitial', () {
    expect(cubit.state, equals(const GarageDetailInitial()));
  });

  blocTest<GarageDetailCubit, GarageDetailState>(
    'emits [GarageDetailLoading, GarageDetailLoaded] when loadGarage succeeds',
    build: () {
      when(mockGetGarageDetail(tGarageId)).thenAnswer((_) async => tGarage);
      return cubit;
    },
    act: (cubit) => cubit.loadGarage(tGarageId),
    expect: () => [
      const GarageDetailLoading(),
      GarageDetailLoaded(tGarage),
    ],
    verify: (_) {
      verify(mockGetGarageDetail(tGarageId)).called(1);
    },
  );

  blocTest<GarageDetailCubit, GarageDetailState>(
    'emits [GarageDetailLoading, GarageDetailError] when loadGarage fails',
    build: () {
      when(mockGetGarageDetail(tGarageId)).thenThrow(Exception('Not found'));
      return cubit;
    },
    act: (cubit) => cubit.loadGarage(tGarageId),
    expect: () => [
      const GarageDetailLoading(),
      const GarageDetailError('Exception: Not found'),
    ],
  );

  blocTest<GarageDetailCubit, GarageDetailState>(
    'emits error immediately when id is empty',
    build: () => cubit,
    act: (cubit) => cubit.loadGarage(''),
    expect: () => [
      const GarageDetailError('Garage ID cannot be empty'),
    ],
    verify: (_) {
      verifyNever(mockGetGarageDetail(any));
    },
  );
}

