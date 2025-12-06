import '../entities/insurance.dart';
import '../repositories/insurance_repository.dart';

/// Use case for fetching a single insurance policy detail
///
/// This is a pure domain use case with no Flutter dependencies.
/// Follows the Single Responsibility Principle - only responsible for
/// fetching a single insurance policy by ID.
class GetInsuranceDetail {
  final InsuranceRepository repository;

  const GetInsuranceDetail(this.repository);

  /// Executes the use case and returns a single insurance policy
  ///
  /// [id] - The unique identifier of the insurance policy
  ///
  /// Throws an exception if:
  /// - The insurance ID is empty or invalid
  /// - The insurance is not found
  /// - The repository operation fails
  Future<Insurance> call(String id) async {
    if (id.isEmpty) {
      throw Exception('Insurance ID cannot be empty');
    }

    try {
      return await repository.getInsurance(id);
    } catch (e) {
      throw Exception('Failed to fetch insurance detail: ${e.toString()}');
    }
  }
}
