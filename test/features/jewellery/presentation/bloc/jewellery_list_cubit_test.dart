import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/features/jewellery/domain/entities/jewellery.dart';
import 'package:assetwize/features/jewellery/domain/usecases/get_jewelleries.dart';
import 'package:assetwize/features/jewellery/presentation/bloc/jewellery_list_cubit.dart';
import 'package:assetwize/features/jewellery/presentation/bloc/jewellery_list_state.dart';

import 'jewellery_list_cubit_test.mocks.dart';

@GenerateMocks([GetJewelleries])
void main() {
  late JewelleryListCubit cubit;
  late MockGetJewelleries mockGetJewelleries;

  setUp(() {
    mockGetJewelleries = MockGetJewelleries();
    cubit = JewelleryListCubit(mockGetJewelleries);
  });

  tearDown(() {
    cubit.close();
  });

  const tJewellery1 = Jewellery(
    id: '1',
    category: 'Gold',
    itemName: 'Gold Ring',
    imageUrl: 'assets/images/gold_insurance.png',
  );

  const tJewellery2 = Jewellery(
    id: '2',
    category: 'Silver',
    itemName: 'Silver Necklace',
    imageUrl: 'assets/images/silver_insurance.png',
  );

  final tJewelleries = [tJewellery1, tJewellery2];

  test('initial state should be JewelleryListInitial', () {
    expect(cubit.state, equals(const JewelleryListInitial()));
  });

  blocTest<JewelleryListCubit, JewelleryListState>(
    'emits [JewelleryListLoading, JewelleryListLoaded] when loadJewelleries succeeds',
    build: () {
      when(mockGetJewelleries()).thenAnswer((_) async => tJewelleries);
      return cubit;
    },
    act: (cubit) => cubit.loadJewelleries(),
    expect: () => [
      const JewelleryListLoading(),
      JewelleryListLoaded(tJewelleries),
    ],
    verify: (_) {
      verify(mockGetJewelleries()).called(1);
    },
  );

  blocTest<JewelleryListCubit, JewelleryListState>(
    'emits [JewelleryListLoading, JewelleryListError] when loadJewelleries fails',
    build: () {
      when(mockGetJewelleries()).thenThrow(Exception('Failed to load'));
      return cubit;
    },
    act: (cubit) => cubit.loadJewelleries(),
    expect: () => [
      const JewelleryListLoading(),
      const JewelleryListError('Failed to load jewellery: Exception: Failed to load'),
    ],
  );

  blocTest<JewelleryListCubit, JewelleryListState>(
    'retry calls loadJewelleries again',
    build: () {
      when(mockGetJewelleries()).thenAnswer((_) async => tJewelleries);
      return cubit;
    },
    act: (cubit) => cubit.retry(),
    expect: () => [
      const JewelleryListLoading(),
      JewelleryListLoaded(tJewelleries),
    ],
    verify: (_) {
      verify(mockGetJewelleries()).called(1);
    },
  );
}

