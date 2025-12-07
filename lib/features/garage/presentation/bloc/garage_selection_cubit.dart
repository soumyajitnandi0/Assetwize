import 'package:flutter_bloc/flutter_bloc.dart';
import 'garage_selection_state.dart';

/// Cubit for managing garage selection state
/// Handles category selection (Car/Bike) and registration number
class GarageSelectionCubit extends Cubit<GarageSelectionState> {
  GarageSelectionCubit() : super(const GarageSelectionInitial());

  /// Selects a vehicle category (Car or Bike)
  void selectCategory(String category) {
    final currentState = state;
    if (currentState is GarageSelectionLoaded) {
      emit(currentState.copyWith(selectedCategory: category));
    } else {
      emit(GarageSelectionLoaded(selectedCategory: category));
    }
  }

  /// Sets the registration number
  void setRegistrationNumber(String registrationNumber) {
    final currentState = state;
    if (currentState is GarageSelectionLoaded) {
      emit(currentState.copyWith(registrationNumber: registrationNumber));
    } else {
      emit(GarageSelectionLoaded(registrationNumber: registrationNumber));
    }
  }

  /// Toggles the acknowledgement checkbox
  void toggleAcknowledged() {
    final currentState = state;
    if (currentState is GarageSelectionLoaded) {
      emit(currentState.copyWith(
        isAcknowledged: !currentState.isAcknowledged,
      ));
    } else {
      emit(const GarageSelectionLoaded(isAcknowledged: true));
    }
  }

  /// Resets the selection state
  void reset() {
    emit(const GarageSelectionInitial());
  }
}

