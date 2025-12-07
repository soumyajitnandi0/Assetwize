import 'package:equatable/equatable.dart';

/// States for realty selection
abstract class RealtySelectionState extends Equatable {
  const RealtySelectionState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class RealtySelectionInitial extends RealtySelectionState {
  const RealtySelectionInitial();
}

/// Loaded state with selection data
class RealtySelectionLoaded extends RealtySelectionState {
  final String? selectedPropertyType; // "House", "Apartment", "Land", "Commercial"
  final String? address;
  final bool isAcknowledged;

  const RealtySelectionLoaded({
    this.selectedPropertyType,
    this.address,
    this.isAcknowledged = false,
  });

  /// Whether the user can continue to the next step
  bool get canContinue {
    return selectedPropertyType != null &&
        address != null &&
        address!.trim().isNotEmpty &&
        isAcknowledged;
  }

  RealtySelectionLoaded copyWith({
    String? selectedPropertyType,
    String? address,
    bool? isAcknowledged,
  }) {
    return RealtySelectionLoaded(
      selectedPropertyType: selectedPropertyType ?? this.selectedPropertyType,
      address: address ?? this.address,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
    );
  }

  @override
  List<Object?> get props => [selectedPropertyType, address, isAcknowledged];
}

