import 'package:flutter_bloc/flutter_bloc.dart';
import 'insurance_selection_state.dart';

/// Cubit for managing insurance selection state
/// Handles category and type selection for new insurance
class InsuranceSelectionCubit extends Cubit<InsuranceSelectionState> {
  InsuranceSelectionCubit() : super(const InsuranceSelectionInitial());

  /// Selects an insurance category (Personal or Asset)
  void selectCategory(String category) {
    final currentState = state;
    if (currentState is InsuranceSelectionLoaded) {
      emit(currentState.copyWith(selectedCategory: category));
    } else {
      emit(InsuranceSelectionLoaded(selectedCategory: category));
    }
  }

  /// Selects an insurance type (Health, Life, Travel, Accident)
  void selectType(String type) {
    final currentState = state;
    if (currentState is InsuranceSelectionLoaded) {
      emit(currentState.copyWith(selectedType: type));
    } else {
      emit(InsuranceSelectionLoaded(selectedType: type));
    }
  }

  /// Resets the selection
  void reset() {
    emit(const InsuranceSelectionInitial());
  }
}
