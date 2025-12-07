import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:assetwize/features/jewellery/data/repositories/jewellery_repository_impl.dart';
import 'package:assetwize/features/jewellery/domain/entities/jewellery.dart';
import 'package:assetwize/core/error/exceptions.dart';

void main() {
  late JewelleryRepositoryImpl repository;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = JewelleryRepositoryImpl();
  });

  tearDown(() async {
    await prefs.clear();
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

  group('getJewelleries', () {
    test('should return empty list when no data is stored', () async {
      // act
      final result = await repository.getJewelleries();

      // assert
      expect(result, isEmpty);
    });

    test('should return list of jewellery items when data exists', () async {
      // arrange
      final jewelleriesJson = json.encode([
        {
          'id': '1',
          'category': 'Gold',
          'itemName': 'Gold Ring',
          'imageUrl': 'assets/images/gold_insurance.png',
        }
      ]);
      await prefs.setString('jewelleries', jewelleriesJson);

      // act
      final result = await repository.getJewelleries();

      // assert
      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.category, 'Gold');
    });

    test('should throw StorageException when data is corrupted', () async {
      // arrange
      await prefs.setString('jewelleries', 'invalid json');

      // act & assert
      expect(
        () => repository.getJewelleries(),
        throwsA(isA<StorageException>()),
      );
    });
  });

  group('getJewellery', () {
    test('should return jewellery when found', () async {
      // arrange
      await repository.addJewellery(tJewellery1);

      // act
      final result = await repository.getJewellery('1');

      // assert
      expect(result.id, '1');
      expect(result.category, 'Gold');
    });

    test('should throw NotFoundException when jewellery not found', () async {
      // act & assert
      expect(
        () => repository.getJewellery('999'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('addJewellery', () {
    test('should add new jewellery successfully', () async {
      // act
      await repository.addJewellery(tJewellery1);

      // assert
      final jewelleries = await repository.getJewelleries();
      expect(jewelleries.length, 1);
      expect(jewelleries.first.id, '1');
    });

    test('should update existing jewellery when ID matches', () async {
      // arrange
      await repository.addJewellery(tJewellery1);
      const updatedJewellery = Jewellery(
        id: '1',
        category: 'Platinum',
        itemName: 'Gold Ring',
        imageUrl: 'assets/images/gold_insurance.png',
      );

      // act
      await repository.addJewellery(updatedJewellery);

      // assert
      final jewelleries = await repository.getJewelleries();
      expect(jewelleries.length, 1);
      expect(jewelleries.first.category, 'Platinum');
    });

    test('should add multiple jewellery items', () async {
      // act
      await repository.addJewellery(tJewellery1);
      await repository.addJewellery(tJewellery2);

      // assert
      final jewelleries = await repository.getJewelleries();
      expect(jewelleries.length, 2);
    });
  });

  group('deleteJewellery', () {
    test('should delete jewellery successfully', () async {
      // arrange
      await repository.addJewellery(tJewellery1);
      await repository.addJewellery(tJewellery2);

      // act
      await repository.deleteJewellery('1');

      // assert
      final jewelleries = await repository.getJewelleries();
      expect(jewelleries.length, 1);
      expect(jewelleries.first.id, '2');
    });

    test('should not throw when deleting non-existent jewellery', () async {
      // act - should not throw, just does nothing
      await repository.deleteJewellery('999');

      // assert - no error thrown
      expect(true, isTrue);
    });
  });

  group('clearAll', () {
    test('should clear all jewellery items', () async {
      // arrange
      await repository.addJewellery(tJewellery1);
      await repository.addJewellery(tJewellery2);

      // act
      await repository.clearAll();

      // assert
      final jewelleries = await repository.getJewelleries();
      expect(jewelleries, isEmpty);
    });
  });
}

