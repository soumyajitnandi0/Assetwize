import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/features/realty/domain/entities/realty.dart';
import 'package:assetwize/features/realty/domain/usecases/get_realties.dart';
import 'package:assetwize/features/realty/presentation/bloc/realty_list_cubit.dart';
import 'package:assetwize/features/realty/presentation/bloc/realty_list_state.dart';

import 'realty_list_cubit_test.mocks.dart';

@GenerateMocks([GetRealties])
void main() {
  late RealtyListCubit cubit;
  late MockGetRealties mockGetRealties;

  setUp(() {
    mockGetRealties = MockGetRealties();
    cubit = RealtyListCubit(mockGetRealties);
  });

  tearDown(() {
    cubit.close();
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

  test('initial state should be RealtyListInitial', () {
    expect(cubit.state, equals(const RealtyListInitial()));
  });

  blocTest<RealtyListCubit, RealtyListState>(
    'emits [RealtyListLoading, RealtyListLoaded] when loadRealties succeeds',
    build: () {
      when(mockGetRealties()).thenAnswer((_) async => tRealties);
      return cubit;
    },
    act: (cubit) => cubit.loadRealties(),
    expect: () => [
      const RealtyListLoading(),
      RealtyListLoaded(tRealties),
    ],
    verify: (_) {
      verify(mockGetRealties()).called(1);
    },
  );

  blocTest<RealtyListCubit, RealtyListState>(
    'emits [RealtyListLoading, RealtyListError] when loadRealties fails',
    build: () {
      when(mockGetRealties()).thenThrow(Exception('Failed to load'));
      return cubit;
    },
    act: (cubit) => cubit.loadRealties(),
    expect: () => [
      const RealtyListLoading(),
      const RealtyListError('Failed to load properties: Exception: Failed to load'),
    ],
  );

  blocTest<RealtyListCubit, RealtyListState>(
    'retry calls loadRealties again',
    build: () {
      when(mockGetRealties()).thenAnswer((_) async => tRealties);
      return cubit;
    },
    act: (cubit) => cubit.retry(),
    expect: () => [
      const RealtyListLoading(),
      RealtyListLoaded(tRealties),
    ],
    verify: (_) {
      verify(mockGetRealties()).called(1);
    },
  );
}

