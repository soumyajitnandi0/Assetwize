import '../../../../core/error/exceptions.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

/// Use case for fetching user profile
///
/// This is a pure domain use case with no Flutter dependencies.
/// Follows the Single Responsibility Principle - only responsible for
/// fetching user profile data.
class GetProfile {
  final ProfileRepository repository;

  const GetProfile(this.repository);

  /// Executes the use case and returns the user profile
  ///
  /// Returns a UserProfile with current user data.
  /// Throws a [StorageException] if the repository operation fails.
  Future<UserProfile> call() async {
    try {
      return await repository.getProfile();
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to fetch profile: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

