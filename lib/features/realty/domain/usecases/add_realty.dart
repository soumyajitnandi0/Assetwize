import '../../../../core/error/exceptions.dart';
import '../entities/realty.dart';
import '../repositories/realty_repository.dart';

/// Use case for adding or updating a realty property
///
/// This is a pure domain use case with no Flutter dependencies.
/// Validates the realty data and saves it to the repository.
class AddRealty {
  final RealtyRepository repository;

  const AddRealty(this.repository);

  /// Executes the use case and saves the realty property
  ///
  /// [realty] - The realty property to save
  ///
  /// Throws [ValidationException] if required fields are missing
  /// Throws [StorageException] if save fails
  Future<void> call(Realty realty) async {
    // Validate required fields
    if (realty.propertyType.trim().isEmpty) {
      throw const ValidationException('Property type cannot be empty');
    }
    if (realty.address.trim().isEmpty) {
      throw const ValidationException('Address cannot be empty');
    }

    try {
      await repository.addRealty(realty);
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to save realty property: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

