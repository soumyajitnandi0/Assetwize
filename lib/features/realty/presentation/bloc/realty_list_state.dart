import 'package:equatable/equatable.dart';
import '../../domain/entities/realty.dart';

/// States for realty list
abstract class RealtyListState extends Equatable {
  const RealtyListState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no data loaded yet
class RealtyListInitial extends RealtyListState {
  const RealtyListInitial();
}

/// Loading state - data is being fetched
class RealtyListLoading extends RealtyListState {
  const RealtyListLoading();
}

/// Loaded state - data successfully fetched
class RealtyListLoaded extends RealtyListState {
  final List<Realty> realties;

  const RealtyListLoaded(this.realties);

  @override
  List<Object?> get props => [realties];
}

/// Error state - data fetch failed
class RealtyListError extends RealtyListState {
  final String message;

  const RealtyListError(this.message);

  @override
  List<Object?> get props => [message];
}

