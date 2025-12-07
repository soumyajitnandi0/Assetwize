import 'package:equatable/equatable.dart';
import '../../../insurance/domain/entities/insurance.dart';
import '../../../garage/domain/entities/garage.dart';
import '../../../jewellery/domain/entities/jewellery.dart';
import '../../../realty/domain/entities/realty.dart';

/// Enum for asset types
enum AssetType {
  insurance,
  garage,
  jewellery,
  realty,
}

/// Unified search result entity that can represent any asset type
class SearchResult extends Equatable {
  final String id;
  final AssetType assetType;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  const SearchResult({
    required this.id,
    required this.assetType,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.metadata,
  });

  /// Creates a SearchResult from an Insurance entity
  factory SearchResult.fromInsurance(Insurance insurance) {
    return SearchResult(
      id: insurance.id,
      assetType: AssetType.insurance,
      title: insurance.title,
      subtitle: '${insurance.provider} • ${insurance.type}',
      imageUrl: insurance.imageUrl,
      metadata: {'insurance': insurance},
    );
  }

  /// Creates a SearchResult from a Garage entity
  factory SearchResult.fromGarage(Garage garage) {
    final vehicleName = garage.make != null || garage.model != null
        ? '${garage.make ?? ''} ${garage.model ?? ''}'.trim()
        : garage.vehicleType;
    return SearchResult(
      id: garage.id,
      assetType: AssetType.garage,
      title: vehicleName,
      subtitle: '${garage.vehicleType} • ${garage.registrationNumber}',
      imageUrl: garage.imageUrl,
      metadata: {'garage': garage},
    );
  }

  /// Creates a SearchResult from a Jewellery entity
  factory SearchResult.fromJewellery(Jewellery jewellery) {
    return SearchResult(
      id: jewellery.id,
      assetType: AssetType.jewellery,
      title: jewellery.displayName,
      subtitle: '${jewellery.category} • ${jewellery.itemName}',
      imageUrl: jewellery.imageUrl,
      metadata: {'jewellery': jewellery},
    );
  }

  /// Creates a SearchResult from a Realty entity
  factory SearchResult.fromRealty(Realty realty) {
    return SearchResult(
      id: realty.id,
      assetType: AssetType.realty,
      title: realty.displayName,
      subtitle: realty.fullAddress,
      imageUrl: realty.imageUrl,
      metadata: {'realty': realty},
    );
  }

  @override
  List<Object?> get props => [id, assetType, title, subtitle, imageUrl, metadata];
}

