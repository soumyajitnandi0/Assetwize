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
  /// Throws an exception if:
  /// - The insurance data is invalid
  /// - The repository operation fails
  Future<void> call(Insurance insurance) async {
    _validateInsurance(insurance);

    try {
      await repository.addInsurance(insurance);
    } catch (e) {
      throw Exception('Failed to save insurance: ${e.toString()}');
    }
  }

  /// Validates insurance data before saving
  void _validateInsurance(Insurance insurance) {
    if (insurance.id.isEmpty) {
      throw Exception('Insurance ID cannot be empty');
    }
    if (insurance.title.trim().isEmpty) {
      throw Exception('Insurance title cannot be empty');
    }
    if (insurance.provider.trim().isEmpty) {
      throw Exception('Insurance provider cannot be empty');
    }
    if (insurance.policyNumber.trim().isEmpty) {
      throw Exception('Policy number cannot be empty');
    }
    if (insurance.endDate.isBefore(insurance.startDate)) {
      throw Exception('End date cannot be before start date');
    }
  }
}
