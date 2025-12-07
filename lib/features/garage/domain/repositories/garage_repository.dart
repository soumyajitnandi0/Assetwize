import '../entities/garage.dart';

/// Abstract repository interface for garage data
/// Implementation: GarageRepositoryImpl (uses SharedPreferences for local storage)
abstract class GarageRepository {
  /// Fetches all vehicles in the garage
  /// Returns a list of Garage entities
  Future<List<Garage>> getGarages();

  /// Fetches a single vehicle by ID
  /// Throws an exception if not found
  Future<Garage> getGarage(String id);

  /// Adds or updates a vehicle
  /// Saves to persistent local storage
  Future<void> addGarage(Garage garage);

  /// Deletes a vehicle by ID
  Future<void> deleteGarage(String id);

  /// Clears all garage data
  Future<void> clearAll();
}

