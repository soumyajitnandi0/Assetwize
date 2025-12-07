import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:assetwize/features/realty/data/repositories/realty_repository_impl.dart';
import 'package:assetwize/features/realty/domain/entities/realty.dart';
import 'package:assetwize/core/error/exceptions.dart';

void main() {
  late RealtyRepositoryImpl repository;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = RealtyRepositoryImpl();
  });

  tearDown(() async {
    await prefs.clear();
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

  group('getRealties', () {
    test('should return empty list when no data is stored', () async {
      // act
      final result = await repository.getRealties();

      // assert
      expect(result, isEmpty);
    });

    test('should return list of realty properties when data exists', () async {
      // arrange
      final realtiesJson = json.encode([
        {
          'id': '1',
          'propertyType': 'House',
          'address': '123 Main St',
          'city': 'Mumbai',
          'state': 'Maharashtra',
          'country': 'India',
          'area': 1500.0,
          'areaUnit': 'sqft',
          'imageUrl': 'assets/images/house.png',
        }
      ]);
      await prefs.setString('realties', realtiesJson);

      // act
      final result = await repository.getRealties();

      // assert
      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.propertyType, 'House');
    });

    test('should throw StorageException when data is corrupted', () async {
      // arrange
      await prefs.setString('realties', 'invalid json');

      // act & assert
      expect(
        () => repository.getRealties(),
        throwsA(isA<StorageException>()),
      );
    });
  });

  group('getRealty', () {
    test('should return realty when found', () async {
      // arrange
      await repository.addRealty(tRealty1);

      // act
      final result = await repository.getRealty('1');

      // assert
      expect(result.id, '1');
      expect(result.propertyType, 'House');
    });

    test('should throw NotFoundException when realty not found', () async {
      // act & assert
      expect(
        () => repository.getRealty('999'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('addRealty', () {
    test('should add new realty successfully', () async {
      // act
      await repository.addRealty(tRealty1);

      // assert
      final realties = await repository.getRealties();
      expect(realties.length, 1);
      expect(realties.first.id, '1');
    });

    test('should update existing realty when ID matches', () async {
      // arrange
      await repository.addRealty(tRealty1);
      const updatedRealty = Realty(
        id: '1',
        propertyType: 'Commercial',
        address: '123 Main St',
        city: 'Mumbai',
        state: 'Maharashtra',
        country: 'India',
        area: 1500.0,
        areaUnit: 'sqft',
        imageUrl: 'assets/images/house.png',
      );

      // act
      await repository.addRealty(updatedRealty);

      // assert
      final realties = await repository.getRealties();
      expect(realties.length, 1);
      expect(realties.first.propertyType, 'Commercial');
    });

    test('should add multiple realty properties', () async {
      // act
      await repository.addRealty(tRealty1);
      await repository.addRealty(tRealty2);

      // assert
      final realties = await repository.getRealties();
      expect(realties.length, 2);
    });
  });

  group('deleteRealty', () {
    test('should delete realty successfully', () async {
      // arrange
      await repository.addRealty(tRealty1);
      await repository.addRealty(tRealty2);

      // act
      await repository.deleteRealty('1');

      // assert
      final realties = await repository.getRealties();
      expect(realties.length, 1);
      expect(realties.first.id, '2');
    });

    test('should not throw when deleting non-existent realty', () async {
      // act - should not throw, just does nothing
      await repository.deleteRealty('999');

      // assert - no error thrown
      expect(true, isTrue);
    });
  });

  group('clearAll', () {
    test('should clear all realty properties', () async {
      // arrange
      await repository.addRealty(tRealty1);
      await repository.addRealty(tRealty2);

      // act
      await repository.clearAll();

      // assert
      final realties = await repository.getRealties();
      expect(realties, isEmpty);
    });
  });
}

