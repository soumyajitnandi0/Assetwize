import 'package:equatable/equatable.dart';
import '../../domain/entities/jewellery.dart';

/// States for JewelleryDetailCubit
abstract class JewelleryDetailState extends Equatable {
  const JewelleryDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no data loaded yet
class JewelleryDetailInitial extends JewelleryDetailState {
  const JewelleryDetailInitial();
}

/// Loading state - fetching data
class JewelleryDetailLoading extends JewelleryDetailState {
  const JewelleryDetailLoading();
}

/// Loaded state - data successfully fetched
class JewelleryDetailLoaded extends JewelleryDetailState {
  final Jewellery jewellery;

  const JewelleryDetailLoaded(this.jewellery);

  @override
  List<Object?> get props => [jewellery];
}

/// Error state - something went wrong
class JewelleryDetailError extends JewelleryDetailState {
  final String message;

  const JewelleryDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

