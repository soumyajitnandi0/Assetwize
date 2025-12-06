import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../../domain/usecases/get_insurances.dart';
import 'insurance_list_state.dart';

/// Cubit for managing insurance list state
///
/// Handles loading, success, and error states with retry logic.
/// Follows BLoC pattern for predictable state management.
///
/// This cubit is responsible for:
/// - Loading the list of insurance policies
/// - Managing loading, success, and error states
/// - Providing retry functionality
class InsuranceListCubit extends Cubit<InsuranceListState> {
  final GetInsurances getInsurances;

  InsuranceListCubit(this.getInsurances) : super(const InsuranceListInitial());

  /// Loads the list of insurances
  ///
  /// Emits [InsuranceListLoading] state first, then either:
  /// - [InsuranceListLoaded] with the list of insurances on success
  /// - [InsuranceListError] with error message on failure
  ///
  /// Prevents duplicate loading requests if already in loading state.
  Future<void> loadInsurances() async {
    // Don't reload if already loading
    if (state is InsuranceListLoading) {
      logger.Logger.debug(
          'InsuranceListCubit: Already loading, skipping request');
      return;
    }

    emit(const InsuranceListLoading());
    logger.Logger.debug('InsuranceListCubit: Loading insurances...');

    try {
      final insurances = await getInsurances();
      emit(InsuranceListLoaded(insurances));
      logger.Logger.info(
          'InsuranceListCubit: Successfully loaded ${insurances.length} insurances');
    } catch (e, stackTrace) {
      final errorMessage = _extractErrorMessage(e);
      emit(InsuranceListError(errorMessage));
      logger.Logger.error(
        'InsuranceListCubit: Failed to load insurances',
        e,
        stackTrace,
      );
    }
  }

  /// Retries loading insurances after an error
  ///
  /// Useful for handling network failures or temporary errors.
  /// Resets the state and attempts to load again.
  Future<void> retry() async {
    logger.Logger.debug('InsuranceListCubit: Retrying load...');
    await loadInsurances();
  }

  /// Extracts a user-friendly error message from an exception
  String _extractErrorMessage(Object error) {
    final errorString = error.toString();
    // Remove "Exception: " prefix if present
    if (errorString.startsWith('Exception: ')) {
      return errorString.substring(11);
    }
    // Return a generic message for unknown errors
    if (errorString.isEmpty) {
      return 'Failed to load insurances. Please try again.';
    }
    return errorString;
  }
}
