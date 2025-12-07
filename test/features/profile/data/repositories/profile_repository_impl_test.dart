import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:assetwize/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:assetwize/core/error/exceptions.dart';

void main() {
  late ProfileRepositoryImpl repository;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = ProfileRepositoryImpl();
  });

  tearDown(() async {
    await prefs.clear();
  });

  group('getProfile', () {
    test('should return empty profile when no data is stored', () async {
      // act
      final result = await repository.getProfile();

      // assert
      expect(result.name, isNull);
      expect(result.phoneNumber, isNull);
      expect(result.email, isNull);
    });

    test('should return profile with stored data', () async {
      // arrange
      await prefs.setString('user_name', 'John Doe');
      await prefs.setString('phone_number', '+1234567890');
      await prefs.setString('email', 'john@example.com');

      // act
      final result = await repository.getProfile();

      // assert
      expect(result.name, 'John Doe');
      expect(result.phoneNumber, '+1234567890');
      expect(result.email, 'john@example.com');
    });
  });

  group('updateName', () {
    test('should save name successfully', () async {
      // arrange
      const name = 'John Doe';

      // act
      await repository.updateName(name);

      // assert
      expect(prefs.getString('user_name'), name);
    });

    test('should throw ValidationException when name is empty', () async {
      // act & assert
      expect(() => repository.updateName(''), throwsA(isA<ValidationException>()));
      expect(() => repository.updateName('   '), throwsA(isA<ValidationException>()));
    });
  });

  group('updatePhoneNumber', () {
    test('should save phone number successfully', () async {
      // arrange
      const phone = '+1234567890';

      // act
      await repository.updatePhoneNumber(phone);

      // assert
      expect(prefs.getString('phone_number'), phone);
    });

    test('should throw ValidationException when phone is empty', () async {
      // act & assert
      expect(() => repository.updatePhoneNumber(''), throwsA(isA<ValidationException>()));
    });
  });

  group('updateEmail', () {
    test('should save email successfully', () async {
      // arrange
      const email = 'john@example.com';

      // act
      await repository.updateEmail(email);

      // assert
      expect(prefs.getString('email'), email);
    });

    test('should throw ValidationException when email is empty', () async {
      // act & assert
      expect(() => repository.updateEmail(''), throwsA(isA<ValidationException>()));
    });
  });

  group('clearProfile', () {
    test('should clear all profile data', () async {
      // arrange
      await prefs.setString('user_name', 'John');
      await prefs.setString('phone_number', '+123');
      await prefs.setString('email', 'john@example.com');

      // act
      await repository.clearProfile();

      // assert
      expect(prefs.getString('user_name'), isNull);
      expect(prefs.getString('phone_number'), isNull);
      expect(prefs.getString('email'), isNull);
    });
  });
}

