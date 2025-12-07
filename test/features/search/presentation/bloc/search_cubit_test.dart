import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/features/search/domain/entities/search_result.dart';
import 'package:assetwize/features/search/domain/usecases/search_all_assets.dart';
import 'package:assetwize/features/search/presentation/bloc/search_cubit.dart';
import 'package:assetwize/features/search/presentation/bloc/search_state.dart';

import 'search_cubit_test.mocks.dart';

@GenerateMocks([SearchAllAssets])
void main() {
  late SearchCubit cubit;
  late MockSearchAllAssets mockSearchAllAssets;

  setUp(() {
    mockSearchAllAssets = MockSearchAllAssets();
    cubit = SearchCubit(mockSearchAllAssets);
  });

  tearDown(() {
    cubit.close();
  });

  const tSearchResult = SearchResult(
    id: '1',
    assetType: AssetType.insurance,
    title: 'Home Insurance',
    subtitle: 'ICICI • Home Insurance',
    imageUrl: 'image.jpg',
  );

  final tResults = [tSearchResult];

  test('initial state should be SearchInitial', () {
    expect(cubit.state, equals(const SearchInitial()));
  });

  blocTest<SearchCubit, SearchState>(
    'emits SearchInitial when query is empty',
    build: () => cubit,
    act: (cubit) => cubit.search('   '),
    expect: () => [const SearchInitial()],
    verify: (_) {
      verifyNever(mockSearchAllAssets(any));
    },
  );

  blocTest<SearchCubit, SearchState>(
    'emits [SearchLoading, SearchLoaded] when search succeeds',
    build: () {
      when(mockSearchAllAssets('test')).thenAnswer((_) async => tResults);
      return cubit;
    },
    act: (cubit) => cubit.search('test'),
    expect: () => [
      const SearchLoading(),
      SearchLoaded(results: tResults, query: 'test'),
    ],
    verify: (_) {
      verify(mockSearchAllAssets('test')).called(1);
    },
  );

  blocTest<SearchCubit, SearchState>(
    'emits [SearchLoading, SearchEmpty] when no results found',
    build: () {
      when(mockSearchAllAssets('test')).thenAnswer((_) async => []);
      return cubit;
    },
    act: (cubit) => cubit.search('test'),
    expect: () => [
      const SearchLoading(),
      const SearchEmpty(query: 'test'),
    ],
  );

  blocTest<SearchCubit, SearchState>(
    'emits [SearchLoading, SearchError] when search fails',
    build: () {
      when(mockSearchAllAssets('test')).thenThrow(Exception('Search failed'));
      return cubit;
    },
    act: (cubit) => cubit.search('test'),
    expect: () => [
      const SearchLoading(),
      isA<SearchError>(),
    ],
  );

  blocTest<SearchCubit, SearchState>(
    'clearSearch resets to SearchInitial',
    build: () => cubit,
    act: (cubit) => cubit.clearSearch(),
    expect: () => [const SearchInitial()],
  );
}

