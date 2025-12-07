import '../../../../core/error/exceptions.dart';
import '../entities/garage.dart';
import '../repositories/garage_repository.dart';

/// Use case for adding or updating a vehicle in the garage
class AddGarage {
  final GarageRepository repository;

  AddGarage(this.repository);

  /// Adds or updates a vehicle
  /// Validates required fields before saving
  /// Throws ValidationException if validation fails
  /// Throws StorageException if save fails
  Future<void> call(Garage garage) async {
    // Validate required fields
    if (garage.vehicleType.isEmpty) {
      throw const ValidationException('Vehicle type is required');
    }
    if (garage.registrationNumber.isEmpty) {
      throw const ValidationException('Registration number is required');
    }

    try {
      await repository.addGarage(garage);
    } catch (e) {
      if (e is ValidationException || e is StorageException) {
        rethrow;
      }
      throw StorageException('Failed to save garage: ${e.toString()}');
    }
  }
}

