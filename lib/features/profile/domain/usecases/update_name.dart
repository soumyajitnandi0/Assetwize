import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../repositories/profile_repository.dart';

/// Use case for updating user's name
///
/// This is a pure domain use case with no Flutter dependencies.
/// Validates the name and updates it in the profile.
class UpdateName {
  final ProfileRepository repository;

  const UpdateName(this.repository);

  /// Executes the use case and updates the name
  ///
  /// [name] - The name to save (must not be empty and meet length requirements)
  /// Throws [ValidationException] if name is invalid
  /// Throws [StorageException] if save fails
  Future<void> call(String name) async {
    final trimmed = name.trim();
    
    if (trimmed.isEmpty) {
      throw const ValidationException('Name cannot be empty');
    }
    
    if (trimmed.length < AppConstants.minNameLength) {
      // ignore: prefer_const_constructors
      throw ValidationException(
        'Name must be at least ${AppConstants.minNameLength} character',
      );
    }
    
    if (trimmed.length > AppConstants.maxNameLength) {
      // ignore: prefer_const_constructors
      throw ValidationException(
        'Name must be at most ${AppConstants.maxNameLength} characters',
      );
    }

    try {
      await repository.updateName(trimmed);
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
}

