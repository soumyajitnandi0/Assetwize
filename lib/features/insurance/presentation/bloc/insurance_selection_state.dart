import 'package:equatable/equatable.dart';

/// States for InsuranceSelectionCubit
abstract class InsuranceSelectionState extends Equatable {
  const InsuranceSelectionState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no selections made
class InsuranceSelectionInitial extends InsuranceSelectionState {
  const InsuranceSelectionInitial();
}

/// State with current selections
class InsuranceSelectionLoaded extends InsuranceSelectionState {
  final String? selectedCategory; // 'Personal' or 'Asset'
  final String? selectedType; // 'Health', 'Life', 'Travel', 'Accident'

  const InsuranceSelectionLoaded({
    this.selectedCategory,
    this.selectedType,
  });

  /// Returns true if both category and type are selected
  bool get canContinue => selectedCategory != null && selectedType != null;

  InsuranceSelectionLoaded copyWith({
    String? selectedCategory,
    String? selectedType,
  }) {
    return InsuranceSelectionLoaded(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedType: selectedType ?? this.selectedType,
    );
  }

  @override
  List<Object?> get props => [selectedCategory, selectedType];
}
