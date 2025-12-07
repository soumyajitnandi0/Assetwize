import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/notification.dart';
import '../bloc/notifications_cubit.dart';
import '../bloc/notifications_state.dart';

/// Notifications page displaying all user notifications
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // Load notifications when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsCubit>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: AppTheme.textPrimary,
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.notifications.isNotEmpty) {
                return TextButton(
                  onPressed: () => context.read<NotificationsCubit>().markAllAsRead(),
                  child: Text(
                    'Mark all read',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          return switch (state) {
            NotificationsLoading() => const _LoadingView(),
            NotificationsError() => _ErrorView(message: state.message),
            NotificationsLoaded() => _NotificationsList(notifications: state.notifications),
            NotificationsInitial() => const _LoadingView(),
            _ => const _LoadingView(),
          };
        },
      ),
    );
  }
}

/// Loading state view
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.primaryGreen,
      ),
    );
  }
}

/// Error state view
class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              message,
              style: GoogleFonts.montserrat(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingL),
            ElevatedButton(
              onPressed: () => context.read<NotificationsCubit>().loadNotifications(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Notifications list view
class _NotificationsList extends StatelessWidget {
  final List<NotificationEntity> notifications;

  const _NotificationsList({required this.notifications});

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              'No notifications',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              'You\'re all caught up!',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _NotificationItem(notification: notification);
      },
    );
  }
}

/// Individual notification item
class _NotificationItem extends StatelessWidget {
  final NotificationEntity notification;
  final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

  _NotificationItem({required this.notification});

  IconData _getIcon(NotificationType type) {
    return switch (type) {
      NotificationType.assetAdded => Icons.add_circle_outline,
      NotificationType.profileUpdated => Icons.person_outline,
      NotificationType.insuranceExpiring => Icons.warning_amber_outlined,
      NotificationType.insuranceExpired => Icons.error_outline,
      NotificationType.general => Icons.info_outline,
    };
  }

  Color _getIconColor(NotificationType type) {
    return switch (type) {
      NotificationType.assetAdded => AppTheme.primaryGreen,
      NotificationType.profileUpdated => AppTheme.primaryGreen,
      NotificationType.insuranceExpiring => AppTheme.warningColor,
      NotificationType.insuranceExpired => AppTheme.errorColor,
      NotificationType.general => AppTheme.textSecondary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppConstants.spacingL),
        color: AppTheme.errorColor,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        context.read<NotificationsCubit>().deleteNotification(notification.id);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!notification.isRead) {
              context.read<NotificationsCubit>().markAsRead(notification.id);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            decoration: BoxDecoration(
              color: notification.isRead
                  ? Colors.white
                  : AppTheme.primaryGreen.withOpacity(0.05),
              border: Border(
                left: BorderSide(
                  color: notification.isRead
                      ? Colors.transparent
                      : AppTheme.primaryGreen,
                  width: 3,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingS),
                  decoration: BoxDecoration(
                    color: _getIconColor(notification.type).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIcon(notification.type),
                    color: _getIconColor(notification.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: notification.isRead
                              ? FontWeight.w500
                              : FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(notification.timestamp),
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

