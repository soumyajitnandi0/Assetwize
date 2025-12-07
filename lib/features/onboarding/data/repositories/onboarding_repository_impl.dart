import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/onboarding_repository.dart';

/// Local implementation of OnboardingRepository
///
/// Uses SharedPreferences for persistent local storage.
class OnboardingRepositoryImpl implements OnboardingRepository {
  static const String _keyIsFirstLaunch = 'is_first_launch';

  @override
  Future<bool> isFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsFirstLaunch) ?? true;
    } catch (e, stackTrace) {
      throw StorageException(
        'Failed to check first launch status: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> setFirstLaunchComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setBool(_keyIsFirstLaunch, false);

      if (!success) {
        throw const StorageException('Failed to mark first launch as complete');
      }
    } catch (e, stackTrace) {
      if (e is StorageException) {
        rethrow;
      }
      throw StorageException(
        'Failed to complete onboarding: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

