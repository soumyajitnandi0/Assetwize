import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:assetwize/features/onboarding/data/repositories/onboarding_repository_impl.dart';

void main() {
  late OnboardingRepositoryImpl repository;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = OnboardingRepositoryImpl();
  });

  tearDown(() async {
    await prefs.clear();
  });

  group('isFirstLaunch', () {
    test('should return true when key does not exist', () async {
      // act
      final result = await repository.isFirstLaunch();

      // assert
      expect(result, isTrue);
    });

    test('should return false when key is set to false', () async {
      // arrange
      await prefs.setBool('is_first_launch', false);

      // act
      final result = await repository.isFirstLaunch();

      // assert
      expect(result, isFalse);
    });

    test('should return true when key is set to true', () async {
      // arrange
      await prefs.setBool('is_first_launch', true);

      // act
      final result = await repository.isFirstLaunch();

      // assert
      expect(result, isTrue);
    });
  });

  group('setFirstLaunchComplete', () {
    test('should set first launch to false', () async {
      // act
      await repository.setFirstLaunchComplete();

      // assert
      expect(prefs.getBool('is_first_launch'), isFalse);
    });
  });
}

