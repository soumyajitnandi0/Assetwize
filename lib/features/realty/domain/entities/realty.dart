import 'package:equatable/equatable.dart';

/// Realty entity representing a real estate property
/// This is a pure domain entity with no Flutter dependencies
class Realty extends Equatable {
  final String id;
  final String propertyType; // "House", "Apartment", "Land", "Commercial"
  final String address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final double? area; // in square feet or square meters
  final String? areaUnit; // "sqft", "sqm"
  final double? purchasePrice;
  final DateTime? purchaseDate;
  final double? currentValue;
  final DateTime? lastValuationDate;
  final String? propertyNumber; // e.g., "Plot No. 123"
  final String? description;
  final String? imageUrl;
  final String? notes;
  final Map<String, dynamic>? metadata; // Additional flexible data

  const Realty({
    required this.id,
    required this.propertyType,
    required this.address,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.area,
    this.areaUnit,
    this.purchasePrice,
    this.purchaseDate,
    this.currentValue,
    this.lastValuationDate,
    this.propertyNumber,
    this.description,
    this.imageUrl,
    this.notes,
    this.metadata,
  });

  /// Returns the full address string
  String get fullAddress {
    final parts = <String>[];
    if (address.isNotEmpty) parts.add(address);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (zipCode != null && zipCode!.isNotEmpty) parts.add(zipCode!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  /// Returns true if valuation is older than 1 year
  bool get isValuationOutdated {
    if (lastValuationDate == null) return true;
    final now = DateTime.now();
    final daysSinceValuation = now.difference(lastValuationDate!).inDays;
    return daysSinceValuation > 365;
  }

  /// Returns the display name for the property
  String get displayName {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }
    return '$propertyType at $address';
  }

  @override
  List<Object?> get props => [
        id,
        propertyType,
        address,
        city,
        state,
        zipCode,
        country,
        area,
        areaUnit,
        purchasePrice,
        purchaseDate,
        currentValue,
        lastValuationDate,
        propertyNumber,
        description,
        imageUrl,
        notes,
        metadata,
      ];
}

