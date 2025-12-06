import '../entities/insurance.dart';
import '../repositories/insurance_repository.dart';

/// Use case for searching insurance policies
///
/// This is a pure domain use case with no Flutter dependencies.
/// Follows the Single Responsibility Principle - only responsible for
/// searching insurance policies by query string.
class SearchInsurances {
  final InsuranceRepository repository;

  const SearchInsurances(this.repository);

  /// Executes the search use case and returns matching insurance policies
  ///
  /// [query] - The search query string to match against insurance fields
  ///
  /// Searches in:
  /// - Title
  /// - Provider
  /// - Policy number
  /// - Type
  /// - Short description (if available)
  ///
  /// Returns an empty list if no matches are found.
  /// Throws an exception if the repository operation fails.
  Future<List<Insurance>> call(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final allInsurances = await repository.getInsurances();
      final searchQuery = query.trim().toLowerCase();

      return allInsurances.where((insurance) {
        // Search in title
        if (insurance.title.toLowerCase().contains(searchQuery)) {
          return true;
        }

        // Search in provider
        if (insurance.provider.toLowerCase().contains(searchQuery)) {
          return true;
        }

        // Search in policy number
        if (insurance.policyNumber.toLowerCase().contains(searchQuery)) {
          return true;
        }

        // Search in type
        if (insurance.type.toLowerCase().contains(searchQuery)) {
          return true;
        }

        // Search in short description (if available)
        if (insurance.shortDescription != null &&
            insurance.shortDescription!
                .toLowerCase()
                .contains(searchQuery)) {
          return true;
        }

        return false;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search insurances: ${e.toString()}');
    }
  }
}


