import '../../../../core/error/exceptions.dart';
import '../entities/realty.dart';
import '../repositories/realty_repository.dart';

/// Use case for fetching a single realty property detail
///
/// This is a pure domain use case with no Flutter dependencies.
/// Follows the Single Responsibility Principle - only responsible for
/// fetching a single realty property by ID.
class GetRealtyDetail {
  final RealtyRepository repository;

  const GetRealtyDetail(this.repository);

  /// Executes the use case and returns a single realty property
  ///
  /// [id] - The unique identifier of the realty property
  ///
  /// Throws [ValidationException] if id is empty
  /// Throws [NotFoundException] if the property is not found
  /// Throws [StorageException] if the repository fails
  Future<Realty> call(String id) async {
    if (id.trim().isEmpty) {
      throw const ValidationException('Realty ID cannot be empty');
    }

    try {
      return await repository.getRealty(id.trim());
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to fetch realty detail: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

