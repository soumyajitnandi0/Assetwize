import 'package:flutter_bloc/flutter_bloc.dart';
import 'jewellery_selection_state.dart';

/// Cubit for managing jewellery selection state
class JewellerySelectionCubit extends Cubit<JewellerySelectionState> {
  JewellerySelectionCubit() : super(const JewellerySelectionInitial());

  /// Selects a jewellery category
  void selectCategory(String category) {
    final currentState = state;
    if (currentState is JewellerySelectionLoaded) {
      emit(currentState.copyWith(selectedCategory: category));
    } else {
      emit(JewellerySelectionLoaded(selectedCategory: category));
    }
  }

  /// Sets the item name
  void setItemName(String itemName) {
    final currentState = state;
    if (currentState is JewellerySelectionLoaded) {
      emit(currentState.copyWith(itemName: itemName));
    } else {
      emit(JewellerySelectionLoaded(itemName: itemName));
    }
  }

  /// Sets the acknowledgment status
  void setAcknowledged(bool acknowledged) {
    final currentState = state;
    if (currentState is JewellerySelectionLoaded) {
      emit(currentState.copyWith(isAcknowledged: acknowledged));
    } else {
      emit(JewellerySelectionLoaded(isAcknowledged: acknowledged));
    }
  }
}

