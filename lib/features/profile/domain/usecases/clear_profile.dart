import '../../../../core/error/exceptions.dart';
import '../repositories/profile_repository.dart';

/// Use case for clearing user profile data
///
/// This is a pure domain use case with no Flutter dependencies.
/// Clears all profile data from storage.
class ClearProfile {
  final ProfileRepository repository;

  const ClearProfile(this.repository);

  /// Executes the use case and clears the profile
  ///
  /// Throws [StorageException] if clear fails
  Future<void> call() async {
    try {
      await repository.clearProfile();
    } catch (e, stackTrace) {
      if (e is AppException) {
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

