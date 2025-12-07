import '../../../../core/error/exceptions.dart';
import '../entities/realty.dart';
import '../repositories/realty_repository.dart';

/// Use case for fetching all realty properties
///
/// This is a pure domain use case with no Flutter dependencies.
/// Follows the Single Responsibility Principle - only responsible for
/// fetching all realty properties.
class GetRealties {
  final RealtyRepository repository;

  const GetRealties(this.repository);

  /// Executes the use case and returns a list of realty properties
  ///
  /// Returns an empty list if no realty properties are found.
  /// Throws [StorageException] if the repository fails
  Future<List<Realty>> call() async {
    try {
      return await repository.getRealties();
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to fetch realty properties: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}

