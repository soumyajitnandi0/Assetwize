import 'package:equatable/equatable.dart';
import '../../domain/entities/jewellery.dart';

/// States for jewellery list
abstract class JewelleryListState extends Equatable {
  const JewelleryListState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no data loaded yet
class JewelleryListInitial extends JewelleryListState {
  const JewelleryListInitial();
}

/// Loading state - data is being fetched
class JewelleryListLoading extends JewelleryListState {
  const JewelleryListLoading();
}

/// Loaded state - data successfully fetched
class JewelleryListLoaded extends JewelleryListState {
  final List<Jewellery> jewelleries;

  const JewelleryListLoaded(this.jewelleries);

  @override
  List<Object?> get props => [jewelleries];
}

/// Error state - data fetch failed
class JewelleryListError extends JewelleryListState {
  final String message;

  const JewelleryListError(this.message);

  @override
  List<Object?> get props => [message];
}

