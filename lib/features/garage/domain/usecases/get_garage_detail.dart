import '../../../../core/error/exceptions.dart';
import '../entities/garage.dart';
import '../repositories/garage_repository.dart';

/// Use case for fetching a single vehicle detail
class GetGarageDetail {
  final GarageRepository repository;

  GetGarageDetail(this.repository);

  /// Fetches a vehicle by ID
  /// Validates that ID is not empty
  /// Throws ValidationException if ID is invalid
  /// Throws NotFoundException if vehicle not found
  /// Throws StorageException if data access fails
  Future<Garage> call(String id) async {
    if (id.isEmpty) {
      throw const ValidationException('Garage ID cannot be empty');
    }

    try {
      return await repository.getGarage(id);
    } catch (e) {
      if (e is ValidationException || e is NotFoundException) {
        rethrow;
      }
      throw StorageException('Failed to fetch garage detail: ${e.toString()}');
    }
  }
}

