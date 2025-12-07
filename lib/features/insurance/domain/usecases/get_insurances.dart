import '../../../../core/error/exceptions.dart';
import '../entities/insurance.dart';
import '../repositories/insurance_repository.dart';

/// Use case for fetching all insurance policies
///
/// This is a pure domain use case with no Flutter dependencies.
/// Follows the Single Responsibility Principle - only responsible for
/// fetching all insurance policies.
class GetInsurances {
  final InsuranceRepository repository;

  const GetInsurances(this.repository);

  /// Executes the use case and returns a list of insurance policies
  ///
  /// Returns an empty list if no insurances are found.
  /// Throws a [StorageException] if the repository operation fails.
  Future<List<Insurance>> call() async {
    try {
      return await repository.getInsurances();
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to fetch insurances: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
