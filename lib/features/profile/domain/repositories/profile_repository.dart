import '../entities/user_profile.dart';

/// Abstract repository interface for user profile data
/// 
/// This interface defines the contract for profile data operations.
/// Implementations can use SharedPreferences, Firestore, or any other storage.
abstract class ProfileRepository {
  /// Fetches the user profile
  /// Returns a UserProfile with current user data
  Future<UserProfile> getProfile();

  /// Updates the user profile
  /// [profile] - The profile data to save
  /// Throws [ValidationException] if validation fails
  /// Throws [StorageException] if save fails
  Future<void> updateProfile(UserProfile profile);

  /// Updates only the user's name
  /// [name] - The name to save
  /// Throws [ValidationException] if name is empty
  /// Throws [StorageException] if save fails
  Future<void> updateName(String name);

  /// Updates only the user's phone number
  /// [phoneNumber] - The phone number to save
  /// Throws [ValidationException] if phone number is invalid
  /// Throws [StorageException] if save fails
  Future<void> updatePhoneNumber(String phoneNumber);

  /// Updates only the user's email
  /// [email] - The email to save
  /// Throws [ValidationException] if email is invalid
  /// Throws [StorageException] if save fails
  Future<void> updateEmail(String email);

  /// Clears all profile data
  /// Throws [StorageException] if clear fails
  Future<void> clearProfile();
}

