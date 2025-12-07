import 'package:equatable/equatable.dart';

/// States for garage selection (category and registration)
abstract class GarageSelectionState extends Equatable {
  const GarageSelectionState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no selection made
class GarageSelectionInitial extends GarageSelectionState {
  const GarageSelectionInitial();
}

/// State with current selections
class GarageSelectionLoaded extends GarageSelectionState {
  final String? selectedCategory; // "Car" or "Bike"
  final String? registrationNumber;
  final bool isAcknowledged;

  const GarageSelectionLoaded({
    this.selectedCategory,
    this.registrationNumber,
    this.isAcknowledged = false,
  });

  /// Returns true if all required fields are filled
  bool get canContinue {
    return selectedCategory != null &&
        registrationNumber != null &&
        registrationNumber!.isNotEmpty &&
        isAcknowledged;
  }

  GarageSelectionLoaded copyWith({
    String? selectedCategory,
    String? registrationNumber,
    bool? isAcknowledged,
  }) {
    return GarageSelectionLoaded(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
    );
  }

  @override
  List<Object?> get props => [
        selectedCategory,
        registrationNumber,
        isAcknowledged,
      ];
}

