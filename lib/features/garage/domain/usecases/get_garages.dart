import '../../../../core/error/exceptions.dart';
import '../entities/garage.dart';
import '../repositories/garage_repository.dart';

/// Use case for fetching all vehicles in the garage
class GetGarages {
  final GarageRepository repository;

  GetGarages(this.repository);

  /// Fetches all vehicles
  /// Returns a list of Garage entities
  /// Throws StorageException if data access fails
  Future<List<Garage>> call() async {
    try {
      return await repository.getGarages();
    } catch (e) {
      if (e is StorageException) {
        rethrow;
      }
      throw StorageException('Failed to fetch garages: ${e.toString()}');
    }
  }
}

