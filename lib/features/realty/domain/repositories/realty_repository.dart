import '../entities/realty.dart';

/// Abstract repository interface for realty data
///
/// This defines the contract for realty data operations.
/// Implementations can use local storage, remote APIs, or both.
abstract class RealtyRepository {
  /// Gets all realty properties
  ///
  /// Returns a list of all realty properties stored.
  /// Returns an empty list if no properties are found.
  Future<List<Realty>> getRealties();

  /// Gets a single realty property by ID
  ///
  /// [id] - The unique identifier of the realty property
  /// Throws [NotFoundException] if the property is not found
  Future<Realty> getRealty(String id);

  /// Adds or updates a realty property
  ///
  /// If the realty has an existing ID, it will be updated.
  /// If the ID is new, a new property will be created.
  /// [realty] - The realty property to save
  Future<void> addRealty(Realty realty);

  /// Deletes a realty property
  ///
  /// [id] - The unique identifier of the realty property to delete
  /// Throws [NotFoundException] if the property is not found
  Future<void> deleteRealty(String id);

  /// Clears all realty data
  ///
  /// Use with caution - this will delete all realty properties.
  Future<void> clearAll();
}

