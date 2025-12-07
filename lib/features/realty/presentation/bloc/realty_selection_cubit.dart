import 'package:flutter_bloc/flutter_bloc.dart';
import 'realty_selection_state.dart';

/// Cubit for managing realty selection state
class RealtySelectionCubit extends Cubit<RealtySelectionState> {
  RealtySelectionCubit() : super(const RealtySelectionInitial());

  /// Selects a property type
  void selectPropertyType(String propertyType) {
    final currentState = state;
    if (currentState is RealtySelectionLoaded) {
      emit(currentState.copyWith(selectedPropertyType: propertyType));
    } else {
      emit(RealtySelectionLoaded(selectedPropertyType: propertyType));
    }
  }

  /// Sets the address
  void setAddress(String address) {
    final currentState = state;
    if (currentState is RealtySelectionLoaded) {
      emit(currentState.copyWith(address: address));
    } else {
      emit(RealtySelectionLoaded(address: address));
    }
  }

  /// Sets the acknowledgment status
  void setAcknowledged(bool acknowledged) {
    final currentState = state;
    if (currentState is RealtySelectionLoaded) {
      emit(currentState.copyWith(isAcknowledged: acknowledged));
    } else {
      emit(RealtySelectionLoaded(isAcknowledged: acknowledged));
    }
  }
}

