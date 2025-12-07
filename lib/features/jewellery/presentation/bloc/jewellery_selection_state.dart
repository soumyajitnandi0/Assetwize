import 'package:equatable/equatable.dart';

/// States for jewellery selection
abstract class JewellerySelectionState extends Equatable {
  const JewellerySelectionState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class JewellerySelectionInitial extends JewellerySelectionState {
  const JewellerySelectionInitial();
}

/// Loaded state with selection data
class JewellerySelectionLoaded extends JewellerySelectionState {
  final String? selectedCategory; // "Gold", "Silver", "Diamond", "Platinum"
  final String? itemName;
  final bool isAcknowledged;

  const JewellerySelectionLoaded({
    this.selectedCategory,
    this.itemName,
    this.isAcknowledged = false,
  });

  /// Whether the user can continue to the next step
  bool get canContinue {
    return selectedCategory != null &&
        itemName != null &&
        itemName!.trim().isNotEmpty &&
        isAcknowledged;
  }

  JewellerySelectionLoaded copyWith({
    String? selectedCategory,
    String? itemName,
    bool? isAcknowledged,
  }) {
    return JewellerySelectionLoaded(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      itemName: itemName ?? this.itemName,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
    );
  }

  @override
  List<Object?> get props => [selectedCategory, itemName, isAcknowledged];
}

