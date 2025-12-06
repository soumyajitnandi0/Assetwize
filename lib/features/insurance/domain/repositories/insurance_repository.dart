import '../entities/insurance.dart';

/// Abstract repository interface for insurance data
/// Implementation: InsuranceRepositoryImpl (uses SharedPreferences for local storage)
abstract class InsuranceRepository {
  /// Fetches all insurance policies
  /// Returns a list of Insurance entities
  Future<List<Insurance>> getInsurances();

  /// Fetches a single insurance policy by ID
  /// Throws an exception if not found
  Future<Insurance> getInsurance(String id);

  /// Adds or updates an insurance policy
  /// Saves to persistent local storage
  Future<void> addInsurance(Insurance insurance);
}
