import 'package:equatable/equatable.dart';
import '../../domain/entities/realty.dart';

/// States for RealtyDetailCubit
abstract class RealtyDetailState extends Equatable {
  const RealtyDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no data loaded yet
class RealtyDetailInitial extends RealtyDetailState {
  const RealtyDetailInitial();
}

/// Loading state - fetching data
class RealtyDetailLoading extends RealtyDetailState {
  const RealtyDetailLoading();
}

/// Loaded state - data successfully fetched
class RealtyDetailLoaded extends RealtyDetailState {
  final Realty realty;

  const RealtyDetailLoaded(this.realty);

  @override
  List<Object?> get props => [realty];
}

/// Error state - something went wrong
class RealtyDetailError extends RealtyDetailState {
  final String message;

  const RealtyDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

