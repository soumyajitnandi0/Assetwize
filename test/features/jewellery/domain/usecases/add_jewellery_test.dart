import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assetwize/core/error/exceptions.dart';
import 'package:assetwize/features/jewellery/domain/entities/jewellery.dart';
import 'package:assetwize/features/jewellery/domain/repositories/jewellery_repository.dart';
import 'package:assetwize/features/jewellery/domain/usecases/add_jewellery.dart';

import 'add_jewellery_test.mocks.dart';

@GenerateMocks([JewelleryRepository])
void main() {
  late AddJewellery usecase;
  late MockJewelleryRepository mockRepository;

  setUp(() {
    mockRepository = MockJewelleryRepository();
    usecase = AddJewellery(mockRepository);
  });

  const tJewellery = Jewellery(
    id: '1',
    category: 'Gold',
    itemName: 'Gold Ring',
    imageUrl: 'assets/images/gold_insurance.png',
  );

  test('should add jewellery successfully', () async {
    // arrange
    when(mockRepository.addJewellery(tJewellery)).thenAnswer((_) async => {});

    // act
    await usecase(tJewellery);

    // assert
    verify(mockRepository.addJewellery(tJewellery));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw ValidationException when category is empty', () async {
    // arrange
    const invalidJewellery = Jewellery(
      id: '1',
      category: '   ',
      itemName: 'Gold Ring',
      imageUrl: 'assets/images/gold_insurance.png',
    );

    // act & assert
    expect(
      () => usecase(invalidJewellery),
      throwsA(isA<ValidationException>()),
    );
    verifyNever(mockRepository.addJewellery(any));
  });

  test('should throw ValidationException when item name is empty', () async {
    // arrange
    const invalidJewellery = Jewellery(
      id: '1',
      category: 'Gold',
      itemName: '   ',
      imageUrl: 'assets/images/gold_insurance.png',
    );

    // act & assert
    expect(
      () => usecase(invalidJewellery),
      throwsA(isA<ValidationException>()),
    );
    verifyNever(mockRepository.addJewellery(any));
  });

  test('should throw StorageException when repository fails', () async {
    // arrange
    when(mockRepository.addJewellery(tJewellery))
        .thenThrow(Exception('Storage error'));

    // act & assert
    expect(
      () => usecase(tJewellery),
      throwsA(isA<StorageException>()),
    );
    verify(mockRepository.addJewellery(tJewellery));
  });
}

