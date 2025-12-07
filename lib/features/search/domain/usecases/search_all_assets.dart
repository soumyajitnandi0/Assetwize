import '../../../../core/error/exceptions.dart';
import '../../../insurance/domain/repositories/insurance_repository.dart';
import '../../../garage/domain/repositories/garage_repository.dart';
import '../../../jewellery/domain/repositories/jewellery_repository.dart';
import '../../../realty/domain/repositories/realty_repository.dart';
import '../entities/search_result.dart';

/// Use case for searching across all asset types
///
/// This is a pure domain use case with no Flutter dependencies.
/// Searches across Insurance, Garage, Jewellery, and Realty assets.
class SearchAllAssets {
  final InsuranceRepository insuranceRepository;
  final GarageRepository garageRepository;
  final JewelleryRepository jewelleryRepository;
  final RealtyRepository realtyRepository;

  const SearchAllAssets(
    this.insuranceRepository,
    this.garageRepository,
    this.jewelleryRepository,
    this.realtyRepository,
  );

  /// Executes the search use case and returns matching assets from all types
  ///
  /// [query] - The search query string to match against asset fields
  ///
  /// Searches in:
  /// - Insurance: title, provider, policy number, type, description
  /// - Garage: vehicle type, registration number, make, model
  /// - Jewellery: category, item name, description
  /// - Realty: property type, address, city, state, description
  ///
  /// Returns an empty list if no matches are found or query is empty.
  /// Throws a [StorageException] if any repository operation fails.
  Future<List<SearchResult>> call(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final searchQuery = query.trim().toLowerCase();
      final results = <SearchResult>[];

      // Search Insurances
      try {
        final insurances = await insuranceRepository.getInsurances();
        for (final insurance in insurances) {
          if (_matchesInsurance(insurance, searchQuery)) {
            results.add(SearchResult.fromInsurance(insurance));
          }
        }
      } catch (e) {
        // Log but don't fail the entire search if one asset type fails
        // Continue searching other asset types
      }

      // Search Garages
      try {
        final garages = await garageRepository.getGarages();
        for (final garage in garages) {
          if (_matchesGarage(garage, searchQuery)) {
            results.add(SearchResult.fromGarage(garage));
          }
        }
      } catch (e) {
        // Log but don't fail the entire search
      }

      // Search Jewellery
      try {
        final jewelleries = await jewelleryRepository.getJewelleries();
        for (final jewellery in jewelleries) {
          if (_matchesJewellery(jewellery, searchQuery)) {
            results.add(SearchResult.fromJewellery(jewellery));
          }
        }
      } catch (e) {
        // Log but don't fail the entire search
      }

      // Search Realty
      try {
        final realties = await realtyRepository.getRealties();
        for (final realty in realties) {
          if (_matchesRealty(realty, searchQuery)) {
            results.add(SearchResult.fromRealty(realty));
          }
        }
      } catch (e) {
        // Log but don't fail the entire search
      }

      return results;
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      throw StorageException(
        'Failed to search assets: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  bool _matchesInsurance(dynamic insurance, String query) {
    return insurance.title.toLowerCase().contains(query) ||
        insurance.provider.toLowerCase().contains(query) ||
        insurance.policyNumber.toLowerCase().contains(query) ||
        insurance.type.toLowerCase().contains(query) ||
        (insurance.shortDescription != null &&
            insurance.shortDescription!.toLowerCase().contains(query));
  }

  bool _matchesGarage(dynamic garage, String query) {
    return garage.vehicleType.toLowerCase().contains(query) ||
        garage.registrationNumber.toLowerCase().contains(query) ||
        (garage.make != null && garage.make!.toLowerCase().contains(query)) ||
        (garage.model != null && garage.model!.toLowerCase().contains(query)) ||
        (garage.color != null && garage.color!.toLowerCase().contains(query));
  }

  bool _matchesJewellery(dynamic jewellery, String query) {
    return jewellery.category.toLowerCase().contains(query) ||
        jewellery.itemName.toLowerCase().contains(query) ||
        (jewellery.description != null &&
            jewellery.description!.toLowerCase().contains(query)) ||
        (jewellery.purity != null &&
            jewellery.purity!.toLowerCase().contains(query));
  }

  bool _matchesRealty(dynamic realty, String query) {
    return realty.propertyType.toLowerCase().contains(query) ||
        realty.address.toLowerCase().contains(query) ||
        (realty.city != null && realty.city!.toLowerCase().contains(query)) ||
        (realty.state != null && realty.state!.toLowerCase().contains(query)) ||
        (realty.description != null &&
            realty.description!.toLowerCase().contains(query)) ||
        (realty.propertyNumber != null &&
            realty.propertyNumber!.toLowerCase().contains(query));
  }
}

