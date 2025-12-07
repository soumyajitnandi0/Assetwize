import '../../../../core/error/exceptions.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

/// Use case for updating user profile
///
/// This is a pure domain use case with no Flutter dependencies.
/// Validates input and updates the user profile.
class UpdateProfile {
  final ProfileRepository repository;

  const UpdateProfile(this.repository);

  /// Executes the use case and updates the profile
  ///
  /// [profile] - The profile data to save
  /// Throws [ValidationException] if validation fails
  /// Throws [StorageException] if save fails
  Future<void> call(UserProfile profile) async {
    try {
      await repository.updateProfile(profile);
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to update profile: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

