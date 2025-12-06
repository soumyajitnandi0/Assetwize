import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart' as logger;

/// Service for managing user preferences and app settings
///
/// Handles local storage of user data like name, preferences, etc.
/// Uses SharedPreferences for persistent storage.
class UserPreferencesService {
  static const String _keyUserName = 'user_name';
  static const String _keyIsFirstLaunch = 'is_first_launch';

  /// Gets the stored user name
  ///
  /// Returns null if no name is stored.
  Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserName);
    } catch (e, stackTrace) {
      logger.Logger.error(
        'Failed to get user name',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// Saves the user name
  ///
  /// [name] - The user's name to save
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> saveUserName(String name) async {
    try {
      if (name.trim().isEmpty) {
        logger.Logger.warning('Attempted to save empty user name');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_keyUserName, name.trim());

      if (success) {
        logger.Logger.info('User name saved: ${name.trim()}');
      } else {
        logger.Logger.warning('Failed to save user name');
      }

      return success;
    } catch (e, stackTrace) {
      logger.Logger.error(
        'Failed to save user name',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Checks if this is the first app launch
  ///
  /// Returns true if it's the first launch, false otherwise.
  Future<bool> isFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsFirstLaunch) ?? true;
    } catch (e, stackTrace) {
      logger.Logger.error(
        'Failed to check first launch status',
        e,
        stackTrace,
      );
      // Default to true to show onboarding if check fails
      return true;
    }
  }

  /// Marks that the app has been launched (not first launch anymore)
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> setFirstLaunchComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setBool(_keyIsFirstLaunch, false);

      if (success) {
        logger.Logger.info('First launch marked as complete');
      }

      return success;
    } catch (e, stackTrace) {
      logger.Logger.error(
        'Failed to mark first launch as complete',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Clears all user preferences (for testing/logout)
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_keyUserName) &&
          await prefs.remove(_keyIsFirstLaunch);

      if (success) {
        logger.Logger.info('User preferences cleared');
      }

      return success;
    } catch (e, stackTrace) {
      logger.Logger.error(
        'Failed to clear user preferences',
        e,
        stackTrace,
      );
      return false;
    }
  }
}
