import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:assetwize/features/garage/data/repositories/garage_repository_impl.dart';
import 'package:assetwize/features/garage/domain/entities/garage.dart';
import 'package:assetwize/core/error/exceptions.dart';

void main() {
  late GarageRepositoryImpl repository;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = GarageRepositoryImpl();
  });

  tearDown(() async {
    await prefs.clear();
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

  group('getGarages', () {
    test('should return empty list when no data is stored', () async {
      // act
      final result = await repository.getGarages();

      // assert
      expect(result, isEmpty);
    });

    test('should return list of garages when data exists', () async {
      // arrange
      final garagesJson = json.encode([
        {
          'id': '1',
          'vehicleType': 'Car',
          'registrationNumber': 'ABC123',
          'imageUrl': 'assets/images/car_insurance.png',
        }
      ]);
      await prefs.setString('garages', garagesJson);

      // act
      final result = await repository.getGarages();

      // assert
      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.vehicleType, 'Car');
    });

    test('should throw StorageException when data is corrupted', () async {
      // arrange
      await prefs.setString('garages', 'invalid json');

      // act & assert
      expect(
        () => repository.getGarages(),
        throwsA(isA<StorageException>()),
      );
    });
  });

  group('getGarage', () {
    test('should return garage when found', () async {
      // arrange
      await repository.addGarage(tGarage1);

      // act
      final result = await repository.getGarage('1');

      // assert
      expect(result.id, '1');
      expect(result.vehicleType, 'Car');
    });

    test('should throw NotFoundException when garage not found', () async {
      // act & assert
      expect(
        () => repository.getGarage('999'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('addGarage', () {
    test('should add new garage successfully', () async {
      // act
      await repository.addGarage(tGarage1);

      // assert
      final garages = await repository.getGarages();
      expect(garages.length, 1);
      expect(garages.first.id, '1');
    });

    test('should update existing garage when ID matches', () async {
      // arrange
      await repository.addGarage(tGarage1);
      const updatedGarage = Garage(
        id: '1',
        vehicleType: 'Truck',
        registrationNumber: 'ABC123',
        imageUrl: 'assets/images/car_insurance.png',
      );

      // act
      await repository.addGarage(updatedGarage);

      // assert
      final garages = await repository.getGarages();
      expect(garages.length, 1);
      expect(garages.first.vehicleType, 'Truck');
    });

    test('should add multiple garages', () async {
      // act
      await repository.addGarage(tGarage1);
      await repository.addGarage(tGarage2);

      // assert
      final garages = await repository.getGarages();
      expect(garages.length, 2);
    });
  });

  group('deleteGarage', () {
    test('should delete garage successfully', () async {
      // arrange
      await repository.addGarage(tGarage1);
      await repository.addGarage(tGarage2);

      // act
      await repository.deleteGarage('1');

      // assert
      final garages = await repository.getGarages();
      expect(garages.length, 1);
      expect(garages.first.id, '2');
    });

    test('should not throw when deleting non-existent garage', () async {
      // act - should not throw, just does nothing
      await repository.deleteGarage('999');

      // assert - no error thrown
      expect(true, isTrue);
    });
  });

  group('clearAll', () {
    test('should clear all garages', () async {
      // arrange
      await repository.addGarage(tGarage1);
      await repository.addGarage(tGarage2);

      // act
      await repository.clearAll();

      // assert
      final garages = await repository.getGarages();
      expect(garages, isEmpty);
    });
  });
}

