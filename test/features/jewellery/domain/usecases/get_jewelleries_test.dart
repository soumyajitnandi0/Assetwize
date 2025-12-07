import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/core/error/exceptions.dart';
import 'package:assetwize/features/jewellery/domain/entities/jewellery.dart';
import 'package:assetwize/features/jewellery/domain/repositories/jewellery_repository.dart';
import 'package:assetwize/features/jewellery/domain/usecases/get_jewelleries.dart';

import 'get_jewelleries_test.mocks.dart';

@GenerateMocks([JewelleryRepository])
void main() {
  late GetJewelleries usecase;
  late MockJewelleryRepository mockRepository;

  setUp(() {
    mockRepository = MockJewelleryRepository();
    usecase = GetJewelleries(mockRepository);
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

  test('should get list of jewellery items from the repository', () async {
    // arrange
    when(mockRepository.getJewelleries()).thenAnswer((_) async => tJewelleries);

    // act
    final result = await usecase();

    // assert
    expect(result, equals(tJewelleries));
    verify(mockRepository.getJewelleries());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw StorageException when repository fails', () async {
    // arrange
    when(mockRepository.getJewelleries())
        .thenThrow(Exception('Failed to fetch'));

    // act & assert
    expect(
      () => usecase(),
      throwsA(isA<StorageException>()),
    );
    verify(mockRepository.getJewelleries());
  });

  test('should return empty list when no jewellery items exist', () async {
    // arrange
    when(mockRepository.getJewelleries()).thenAnswer((_) async => []);

    // act
    final result = await usecase();

    // assert
    expect(result, isEmpty);
    verify(mockRepository.getJewelleries());
  });
}

