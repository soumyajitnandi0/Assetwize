import '../../../../core/error/exceptions.dart';
import '../entities/insurance.dart';
import '../repositories/insurance_repository.dart';

/// Use case for adding or updating an insurance policy
///
/// This is a pure domain use case with no Flutter dependencies.
/// Follows the Single Responsibility Principle - only responsible for
/// adding or updating insurance policies.
class AddInsurance {
  final InsuranceRepository repository;

  const AddInsurance(this.repository);

  /// Executes the use case and adds or updates an insurance policy
  ///
  /// [insurance] - The insurance entity to be saved
  ///
  /// Throws a [ValidationException] if the insurance data is invalid.
  /// Throws a [StorageException] if the repository operation fails.
  Future<void> call(Insurance insurance) async {
    _validateInsurance(insurance);

    try {
      await repository.addInsurance(insurance);
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to save insurance: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Validates insurance data before saving
  ///
  /// Throws [ValidationException] if validation fails.
  void _validateInsurance(Insurance insurance) {
    if (insurance.id.isEmpty) {
      throw const ValidationException('Insurance ID cannot be empty');
    }
    if (insurance.title.trim().isEmpty) {
      throw const ValidationException('Insurance title cannot be empty');
    }
    if (insurance.provider.trim().isEmpty) {
      throw const ValidationException('Insurance provider cannot be empty');
    }
    if (insurance.policyNumber.trim().isEmpty) {
      throw const ValidationException('Policy number cannot be empty');
    }
    if (insurance.endDate.isBefore(insurance.startDate)) {
      throw const ValidationException('End date cannot be before start date');
    }
  }
}
