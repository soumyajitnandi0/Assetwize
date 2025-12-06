import 'package:equatable/equatable.dart';
import '../../domain/entities/insurance.dart';

/// States for InsuranceListCubit
abstract class InsuranceListState extends Equatable {
  const InsuranceListState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no data loaded yet
class InsuranceListInitial extends InsuranceListState {
  const InsuranceListInitial();
}

/// Loading state - fetching data
class InsuranceListLoading extends InsuranceListState {
  const InsuranceListLoading();
}

/// Loaded state - data successfully fetched
class InsuranceListLoaded extends InsuranceListState {
  final List<Insurance> insurances;

  const InsuranceListLoaded(this.insurances);

  @override
  List<Object?> get props => [insurances];
}

/// Error state - something went wrong
class InsuranceListError extends InsuranceListState {
  final String message;

  const InsuranceListError(this.message);

  @override
  List<Object?> get props => [message];
}
