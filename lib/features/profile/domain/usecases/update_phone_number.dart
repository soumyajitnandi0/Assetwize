import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../repositories/profile_repository.dart';

/// Use case for updating user's phone number
///
/// This is a pure domain use case with no Flutter dependencies.
/// Validates the phone number and updates it in the profile.
class UpdatePhoneNumber {
  final ProfileRepository repository;

  const UpdatePhoneNumber(this.repository);

  /// Executes the use case and updates the phone number
  ///
  /// [phoneNumber] - The phone number to save (must not be empty and meet length requirements)
  /// Throws [ValidationException] if phone number is invalid
  /// Throws [StorageException] if save fails
  Future<void> call(String phoneNumber) async {
    final trimmed = phoneNumber.trim();
    
    if (trimmed.isEmpty) {
      throw const ValidationException('Phone number cannot be empty');
    }
    
    // Remove common formatting characters for validation
    final cleaned = trimmed.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    if (cleaned.length < AppConstants.minPhoneLength) {
      // ignore: prefer_const_constructors
      throw ValidationException(
        'Phone number must be at least ${AppConstants.minPhoneLength} digits',
      );
    }
    
    if (cleaned.length > AppConstants.maxPhoneLength) {
      // ignore: prefer_const_constructors
      throw ValidationException(
        'Phone number must be at most ${AppConstants.maxPhoneLength} digits',
      );
    }
    
    // Validate format
    final phoneRegex = RegExp(r'^\+?[0-9]+$');
    if (!phoneRegex.hasMatch(cleaned)) {
      throw const ValidationException('Please enter a valid phone number');
    }

    try {
      await repository.updatePhoneNumber(trimmed);
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
}

