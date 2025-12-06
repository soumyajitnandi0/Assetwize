import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart' as logger;

/// Service for managing user preferences and app settings
///
/// Handles local storage of user data like name, preferences, etc.
/// Uses SharedPreferences for persistent storage.
class UserPreferencesService {
  static const String _keyUserName = 'user_name';
  static const String _keyPhoneNumber = 'phone_number';
  static const String _keyEmail = 'email';
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

  /// Gets the stored phone number
  ///
  /// Returns null if no phone number is stored.
  Future<String?> getPhoneNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyPhoneNumber);
    } catch (e, stackTrace) {
      logger.Logger.error(
        'Failed to get phone number',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// Saves the phone number
  ///
  /// [phoneNumber] - The user's phone number to save
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> savePhoneNumber(String phoneNumber) async {
    try {
      if (phoneNumber.trim().isEmpty) {
        logger.Logger.warning('Attempted to save empty phone number');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_keyPhoneNumber, phoneNumber.trim());

      if (success) {
        logger.Logger.info('Phone number saved: ${phoneNumber.trim()}');
      } else {
        logger.Logger.warning('Failed to save phone number');
      }

      return success;
    } catch (e, stackTrace) {
      logger.Logger.error(
        'Failed to save phone number',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Gets the stored email
  ///
  /// Returns null if no email is stored.
  Future<String?> getEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyEmail);
    } catch (e, stackTrace) {
      logger.Logger.error(
        'Failed to get email',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// Saves the email
  ///
  /// [email] - The user's email to save
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> saveEmail(String email) async {
    try {
      if (email.trim().isEmpty) {
        logger.Logger.warning('Attempted to save empty email');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_keyEmail, email.trim());

      if (success) {
        logger.Logger.info('Email saved: ${email.trim()}');
      } else {
        logger.Logger.warning('Failed to save email');
      }

      return success;
    } catch (e, stackTrace) {
      logger.Logger.error(
        'Failed to save email',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Calculates profile completion percentage
  ///
  /// Returns a value between 0 and 100 based on filled fields.
  Future<int> getProfileCompletion() async {
    try {
      int completed = 0;
      const int total = 3; // Name, Phone, Email

      final name = await getUserName();
      if (name != null && name.isNotEmpty) completed++;

      final phone = await getPhoneNumber();
      if (phone != null && phone.isNotEmpty) completed++;

      final email = await getEmail();
      if (email != null && email.isNotEmpty) completed++;

      return ((completed / total) * 100).round();
    } catch (e) {
      logger.Logger.error('Failed to calculate profile completion', e);
      return 0;
    }
  }

  /// Resets the app to first launch state
  /// 
  /// Clears user name, phone number, email and sets first launch flag to true.
  /// Returns true if successful, false otherwise.
  Future<bool> resetToFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_keyUserName) &&
          await prefs.remove(_keyPhoneNumber) &&
          await prefs.remove(_keyEmail) &&
          await prefs.setBool(_keyIsFirstLaunch, true);

      if (success) {
        logger.Logger.info('App reset to first launch state');
      }

      return success;
    } catch (e, stackTrace) {
      logger.Logger.error(
        'Failed to reset to first launch',
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
          await prefs.remove(_keyPhoneNumber) &&
          await prefs.remove(_keyEmail) &&
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
