import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/core/error/exceptions.dart';
import 'package:assetwize/features/jewellery/domain/entities/jewellery.dart';
import 'package:assetwize/features/jewellery/domain/repositories/jewellery_repository.dart';
import 'package:assetwize/features/jewellery/domain/usecases/get_jewellery_detail.dart';

import 'get_jewellery_detail_test.mocks.dart';

@GenerateMocks([JewelleryRepository])
void main() {
  late GetJewelleryDetail usecase;
  late MockJewelleryRepository mockRepository;

  setUp(() {
    mockRepository = MockJewelleryRepository();
    usecase = GetJewelleryDetail(mockRepository);
  });

  const tJewellery = Jewellery(
    id: '1',
    category: 'Gold',
    itemName: 'Gold Ring',
    imageUrl: 'assets/images/gold_insurance.png',
  );

  const tId = '1';

  test('should get jewellery detail from the repository', () async {
    // arrange
    when(mockRepository.getJewellery(tId)).thenAnswer((_) async => tJewellery);

    // act
    final result = await usecase(tId);

    // assert
    expect(result, equals(tJewellery));
    verify(mockRepository.getJewellery(tId));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw ValidationException when ID is empty', () async {
    // act & assert
    expect(
      () => usecase(''),
      throwsA(isA<ValidationException>()),
    );
    verifyNever(mockRepository.getJewellery(any));
  });

  test('should throw StorageException when repository fails', () async {
    // arrange
    when(mockRepository.getJewellery(tId))
        .thenThrow(Exception('Jewellery not found'));

    // act & assert
    expect(
      () => usecase(tId),
      throwsA(isA<StorageException>()),
    );
    verify(mockRepository.getJewellery(tId));
  });
}

