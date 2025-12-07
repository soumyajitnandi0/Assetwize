import 'package:equatable/equatable.dart';

/// Insurance entity representing an insurance policy
/// This is a pure domain entity with no Flutter dependencies
class Insurance extends Equatable {
  final String id;
  final String title;
  final String provider;
  final String policyNumber;
  final DateTime startDate;
  final DateTime endDate;
  final String imageUrl;
  final String? shortDescription;
  final String type; // e.g., "Home Insurance", "Life Insurance"
  final String? coverage; // Coverage amount (e.g., "₹5,00,000" or "500000")
  final Map<String, dynamic>? metadata; // Additional flexible data

  /// Number of days before insurance expiry to show "expiring soon" warning
  /// This is a domain constant, not a UI constant
  static const int expiringSoonDays = 30;

  const Insurance({
    required this.id,
    required this.title,
    required this.provider,
    required this.policyNumber,
    required this.startDate,
    required this.endDate,
    required this.imageUrl,
    this.shortDescription,
    required this.type,
    this.coverage,
    this.metadata,
  });

  /// Returns true if the insurance is expiring within the configured days
  bool get isExpiringSoon {
    final now = DateTime.now();
    final daysUntilExpiry = endDate.difference(now).inDays;
    return daysUntilExpiry > 0 && 
           daysUntilExpiry <= expiringSoonDays;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        provider,
        policyNumber,
        startDate,
        endDate,
        imageUrl,
        shortDescription,
        type,
        coverage,
        metadata,
      ];
}
