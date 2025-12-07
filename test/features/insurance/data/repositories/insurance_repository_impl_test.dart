import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:assetwize/features/insurance/data/repositories/insurance_repository_impl.dart';
import 'package:assetwize/features/insurance/domain/entities/insurance.dart';
import 'package:assetwize/core/error/exceptions.dart';

void main() {
  late InsuranceRepositoryImpl repository;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = InsuranceRepositoryImpl();
  });

  tearDown(() async {
    await prefs.clear();
  });

  final tInsurance1 = Insurance(
    id: '1',
    title: 'Home Insurance',
    provider: 'ICICI',
    policyNumber: 'POL123',
    startDate: DateTime(2024, 1, 1),
    endDate: DateTime(2025, 1, 1),
    imageUrl: 'image1.jpg',
    type: 'Home',
  );

  final tInsurance2 = Insurance(
    id: '2',
    title: 'Life Insurance',
    provider: 'LIC',
    policyNumber: 'POL456',
    startDate: DateTime(2023, 6, 1),
    endDate: DateTime(2024, 6, 1),
    imageUrl: 'image2.jpg',
    type: 'Life',
  );

  group('getInsurances', () {
    test('should return empty list when no data is stored', () async {
      // act
      final result = await repository.getInsurances();

      // assert
      expect(result, isEmpty);
    });

    test('should return list of insurances when data exists', () async {
      // arrange
      final insurancesJson = json.encode([
        {
          'id': '1',
          'title': 'Home Insurance',
          'provider': 'ICICI',
          'policyNumber': 'POL123',
          'startDate': '2024-01-01T00:00:00.000',
          'endDate': '2025-01-01T00:00:00.000',
          'imageUrl': 'image1.jpg',
          'type': 'Home',
        }
      ]);
      await prefs.setString('insurances', insurancesJson);

      // act
      final result = await repository.getInsurances();

      // assert
      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.title, 'Home Insurance');
    });

    test('should throw StorageException when data is corrupted', () async {
      // arrange
      await prefs.setString('insurances', 'invalid json');

      // act & assert
      expect(
        () => repository.getInsurances(),
        throwsA(isA<StorageException>()),
      );
    });
  });

  group('getInsurance', () {
    test('should return insurance when found', () async {
      // arrange
      await repository.addInsurance(tInsurance1);

      // act
      final result = await repository.getInsurance('1');

      // assert
      expect(result.id, '1');
      expect(result.title, 'Home Insurance');
    });

    test('should throw NotFoundException when insurance not found', () async {
      // act & assert
      expect(
        () => repository.getInsurance('999'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('addInsurance', () {
    test('should add new insurance successfully', () async {
      // act
      await repository.addInsurance(tInsurance1);

      // assert
      final insurances = await repository.getInsurances();
      expect(insurances.length, 1);
      expect(insurances.first.id, '1');
    });

    test('should update existing insurance when ID matches', () async {
      // arrange
      await repository.addInsurance(tInsurance1);
      final updatedInsurance = Insurance(
        id: '1',
        title: 'Updated Home Insurance',
        provider: 'ICICI',
        policyNumber: 'POL123',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2025, 1, 1),
        imageUrl: 'image1.jpg',
        type: 'Home',
      );

      // act
      await repository.addInsurance(updatedInsurance);

      // assert
      final insurances = await repository.getInsurances();
      expect(insurances.length, 1);
      expect(insurances.first.title, 'Updated Home Insurance');
    });

    test('should add multiple insurances', () async {
      // act
      await repository.addInsurance(tInsurance1);
      await repository.addInsurance(tInsurance2);

      // assert
      final insurances = await repository.getInsurances();
      expect(insurances.length, 2);
    });
  });


  group('clearAll', () {
    test('should clear all insurances', () async {
      // arrange
      await repository.addInsurance(tInsurance1);
      await repository.addInsurance(tInsurance2);

      // act
      await repository.clearAll();

      // assert
      final insurances = await repository.getInsurances();
      expect(insurances, isEmpty);
    });
  });
}

