import 'package:equatable/equatable.dart';

/// Jewellery entity representing a jewellery item
/// This is a pure domain entity with no Flutter dependencies
class Jewellery extends Equatable {
  final String id;
  final String category; // "Gold", "Silver", "Diamond", "Platinum"
  final String itemName; // e.g., "Necklace", "Ring", "Earrings"
  final String? description;
  final double? weight; // in grams
  final String? purity; // e.g., "22K", "24K", "925"
  final double? purchasePrice;
  final DateTime? purchaseDate;
  final String? purchaseLocation;
  final double? currentValue;
  final DateTime? lastValuationDate;
  final String? imageUrl;
  final String? notes;
  final Map<String, dynamic>? metadata; // Additional flexible data

  const Jewellery({
    required this.id,
    required this.category,
    required this.itemName,
    this.description,
    this.weight,
    this.purity,
    this.purchasePrice,
    this.purchaseDate,
    this.purchaseLocation,
    this.currentValue,
    this.lastValuationDate,
    this.imageUrl,
    this.notes,
    this.metadata,
  });

  /// Returns true if valuation is older than 1 year
  bool get isValuationOutdated {
    if (lastValuationDate == null) return true;
    final now = DateTime.now();
    final daysSinceValuation = now.difference(lastValuationDate!).inDays;
    return daysSinceValuation > 365;
  }

  /// Returns the display name for the jewellery item
  String get displayName {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }
    return '$category $itemName';
  }

  @override
  List<Object?> get props => [
        id,
        category,
        itemName,
        description,
        weight,
        purity,
        purchasePrice,
        purchaseDate,
        purchaseLocation,
        currentValue,
        lastValuationDate,
        imageUrl,
        notes,
        metadata,
      ];
}

