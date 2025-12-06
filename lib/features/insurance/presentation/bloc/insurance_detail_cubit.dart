import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../../domain/usecases/get_insurance_detail.dart';
import 'insurance_detail_state.dart';

/// Cubit for managing insurance detail state
///
/// Handles loading, success, and error states with retry logic.
/// Follows BLoC pattern for predictable state management.
///
/// This cubit is responsible for:
/// - Loading a single insurance policy by ID
/// - Managing loading, success, and error states
/// - Providing retry functionality
class InsuranceDetailCubit extends Cubit<InsuranceDetailState> {
  final GetInsuranceDetail getInsuranceDetail;

  InsuranceDetailCubit(this.getInsuranceDetail)
      : super(const InsuranceDetailInitial());

  /// Loads a single insurance by ID
  ///
  /// [id] - The unique identifier of the insurance policy
  ///
  /// Emits [InsuranceDetailLoading] state first, then either:
  /// - [InsuranceDetailLoaded] with the insurance on success
  /// - [InsuranceDetailError] with error message on failure
  ///
  /// Validates the ID before attempting to load.
  /// Prevents duplicate loading requests if already in loading state.
  Future<void> loadInsurance(String id) async {
    if (id.isEmpty) {
      const errorMessage = 'Insurance ID cannot be empty';
      emit(const InsuranceDetailError(errorMessage));
      logger.Logger.warning('InsuranceDetailCubit: Empty ID provided');
      return;
    }

    // Don't reload if already loading
    if (state is InsuranceDetailLoading) {
      logger.Logger.debug(
          'InsuranceDetailCubit: Already loading, skipping request');
      return;
    }

    emit(const InsuranceDetailLoading());
    logger.Logger.debug('InsuranceDetailCubit: Loading insurance with ID: $id');

    try {
      final insurance = await getInsuranceDetail(id);
      emit(InsuranceDetailLoaded(insurance));
      logger.Logger.info(
          'InsuranceDetailCubit: Successfully loaded insurance: ${insurance.title}');
    } catch (e, stackTrace) {
      final errorMessage = _extractErrorMessage(e);
      emit(InsuranceDetailError(errorMessage));
      logger.Logger.error(
        'InsuranceDetailCubit: Failed to load insurance with ID: $id',
        e,
        stackTrace,
      );
    }
  }

  /// Retries loading insurance after an error
  ///
  /// [id] - The unique identifier of the insurance policy
  ///
  /// Useful for handling network failures or temporary errors.
  /// Resets the state and attempts to load again.
  Future<void> retry(String id) async {
    logger.Logger.debug('InsuranceDetailCubit: Retrying load for ID: $id');
    await loadInsurance(id);
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
      return 'Failed to load insurance details. Please try again.';
    }
    return errorString;
  }
}
