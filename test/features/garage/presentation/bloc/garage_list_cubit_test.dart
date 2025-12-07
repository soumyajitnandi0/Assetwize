import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/features/garage/domain/entities/garage.dart';
import 'package:assetwize/features/garage/domain/usecases/get_garages.dart';
import 'package:assetwize/features/garage/presentation/bloc/garage_list_cubit.dart';
import 'package:assetwize/features/garage/presentation/bloc/garage_list_state.dart';

import 'garage_list_cubit_test.mocks.dart';

@GenerateMocks([GetGarages])
void main() {
  late GarageListCubit cubit;
  late MockGetGarages mockGetGarages;

  setUp(() {
    mockGetGarages = MockGetGarages();
    cubit = GarageListCubit(mockGetGarages);
  });

  tearDown(() {
    cubit.close();
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

  test('initial state should be GarageListInitial', () {
    expect(cubit.state, equals(const GarageListInitial()));
  });

  blocTest<GarageListCubit, GarageListState>(
    'emits [GarageListLoading, GarageListLoaded] when loadGarages succeeds',
    build: () {
      when(mockGetGarages()).thenAnswer((_) async => tGarages);
      return cubit;
    },
    act: (cubit) => cubit.loadGarages(),
    expect: () => [
      const GarageListLoading(),
      GarageListLoaded(tGarages),
    ],
    verify: (_) {
      verify(mockGetGarages()).called(1);
    },
  );

  blocTest<GarageListCubit, GarageListState>(
    'emits [GarageListLoading, GarageListError] when loadGarages fails',
    build: () {
      when(mockGetGarages()).thenThrow(Exception('Failed to load'));
      return cubit;
    },
    act: (cubit) => cubit.loadGarages(),
    expect: () => [
      const GarageListLoading(),
      const GarageListError('Failed to load vehicles: Exception: Failed to load'),
    ],
  );

  blocTest<GarageListCubit, GarageListState>(
    'retry calls loadGarages again',
    build: () {
      when(mockGetGarages()).thenAnswer((_) async => tGarages);
      return cubit;
    },
    act: (cubit) => cubit.retry(),
    expect: () => [
      const GarageListLoading(),
      GarageListLoaded(tGarages),
    ],
    verify: (_) {
      verify(mockGetGarages()).called(1);
    },
  );
}

