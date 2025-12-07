import '../../../../core/error/exceptions.dart';
import '../repositories/profile_repository.dart';

/// Use case for updating user's email
///
/// This is a pure domain use case with no Flutter dependencies.
/// Validates the email format and updates it in the profile.
class UpdateEmail {
  final ProfileRepository repository;

  const UpdateEmail(this.repository);

  /// Executes the use case and updates the email
  ///
  /// [email] - The email to save (must not be empty and be valid format)
  /// Throws [ValidationException] if email is invalid
  /// Throws [StorageException] if save fails
  Future<void> call(String email) async {
    final trimmed = email.trim();
    
    if (trimmed.isEmpty) {
      throw const ValidationException('Email cannot be empty');
    }
    
    // Validate email format
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(trimmed)) {
      throw const ValidationException('Please enter a valid email address');
    }

    try {
      await repository.updateEmail(trimmed);
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
}

