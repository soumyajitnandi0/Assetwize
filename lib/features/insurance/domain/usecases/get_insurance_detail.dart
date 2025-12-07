import '../../../../core/error/exceptions.dart';
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
  /// Throws a [ValidationException] if the insurance ID is empty.
  /// Throws a [StorageException] if the repository operation fails.
  Future<Insurance> call(String id) async {
    if (id.isEmpty) {
      throw const ValidationException('Insurance ID cannot be empty');
    }

    try {
      return await repository.getInsurance(id);
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to fetch insurance detail: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
