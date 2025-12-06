import 'package:equatable/equatable.dart';
import '../../domain/entities/insurance.dart';

/// States for InsuranceDetailCubit
abstract class InsuranceDetailState extends Equatable {
  const InsuranceDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no data loaded yet
class InsuranceDetailInitial extends InsuranceDetailState {
  const InsuranceDetailInitial();
}

/// Loading state - fetching data
class InsuranceDetailLoading extends InsuranceDetailState {
  const InsuranceDetailLoading();
}

/// Loaded state - data successfully fetched
class InsuranceDetailLoaded extends InsuranceDetailState {
  final Insurance insurance;

  const InsuranceDetailLoaded(this.insurance);

  @override
  List<Object?> get props => [insurance];
}

/// Error state - something went wrong
class InsuranceDetailError extends InsuranceDetailState {
  final String message;

  const InsuranceDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
