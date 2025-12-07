import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/user_profile_model.dart';

/// Local implementation of ProfileRepository
///
/// Uses SharedPreferences for persistent local storage.
/// This implementation provides a simple, local-first data storage solution.
///
/// For production use with cloud sync, consider implementing
/// a Firestore-based repository.
class ProfileRepositoryImpl implements ProfileRepository {
  static const String _keyUserName = 'user_name';
  static const String _keyPhoneNumber = 'phone_number';
  static const String _keyEmail = 'email';

  @override
  Future<UserProfile> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return UserProfileModel(
        name: prefs.getString(_keyUserName),
        phoneNumber: prefs.getString(_keyPhoneNumber),
        email: prefs.getString(_keyEmail),
      );
    } catch (e, stackTrace) {
      throw StorageException(
        'Failed to fetch profile: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final updates = <String, bool>{};

      if (profile.name != null) {
        updates[_keyUserName] = await prefs.setString(_keyUserName, profile.name!);
      }
      if (profile.phoneNumber != null) {
        updates[_keyPhoneNumber] = await prefs.setString(_keyPhoneNumber, profile.phoneNumber!);
      }
      if (profile.email != null) {
        updates[_keyEmail] = await prefs.setString(_keyEmail, profile.email!);
      }

      // Check if all updates succeeded
      if (updates.values.any((success) => !success)) {
        throw const StorageException('Failed to save some profile fields');
      }
    } catch (e, stackTrace) {
      if (e is StorageException) {
        rethrow;
      }
      throw StorageException(
        'Failed to update profile: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateName(String name) async {
    if (name.trim().isEmpty) {
      throw const ValidationException('Name cannot be empty');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_keyUserName, name.trim());

      if (!success) {
        throw const StorageException('Failed to save name');
      }
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to update name: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updatePhoneNumber(String phoneNumber) async {
    if (phoneNumber.trim().isEmpty) {
      throw const ValidationException('Phone number cannot be empty');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_keyPhoneNumber, phoneNumber.trim());

      if (!success) {
        throw const StorageException('Failed to save phone number');
      }
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to update phone number: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateEmail(String email) async {
    if (email.trim().isEmpty) {
      throw const ValidationException('Email cannot be empty');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_keyEmail, email.trim());

      if (!success) {
        throw const StorageException('Failed to save email');
      }
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to update email: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final results = await Future.wait([
        prefs.remove(_keyUserName),
        prefs.remove(_keyPhoneNumber),
        prefs.remove(_keyEmail),
      ]);

      if (results.any((success) => !success)) {
        throw const StorageException('Failed to clear some profile fields');
      }
    } catch (e, stackTrace) {
      if (e is StorageException) {
        rethrow;
      }
      throw StorageException(
        'Failed to clear profile: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

