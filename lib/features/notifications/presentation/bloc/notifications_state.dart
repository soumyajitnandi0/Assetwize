import 'package:equatable/equatable.dart';
import '../../domain/entities/notification.dart';

/// Base class for notifications states
abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

/// Initial state when notifications page is first loaded
class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

/// State when notifications are being loaded
class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

/// State when notifications have been loaded successfully
class NotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> notifications;

  const NotificationsLoaded({required this.notifications});

  @override
  List<Object?> get props => [notifications];
}

/// State when loading notifications encounters an error
class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}

