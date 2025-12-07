import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/user_preferences_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../../../../core/widgets/error_boundary.dart';
import '../../../insurance/domain/repositories/insurance_repository.dart';
import '../../../notifications/presentation/bloc/notifications_cubit.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../onboarding/presentation/pages/welcome_page.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_item.dart';

/// Profile/Settings page
/// Displays user profile information and app settings
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _unreadCount = 0;
  StreamSubscription<int>? _unreadCountSubscription;
  final _notificationService = sl<NotificationService>();

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    // Listen to unread count stream for real-time updates
    _unreadCountSubscription = _notificationService.unreadCountStream.listen(
      (count) {
        if (mounted) {
          setState(() {
            _unreadCount = count;
          });
        }
      },
      onError: (error) {
        logger.Logger.error('ProfilePage: Error in unread count stream', error);
      },
    );
  }

  @override
  void dispose() {
    _unreadCountSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUnreadCount() async {
    final count = await _notificationService.getUnreadCount();
    if (mounted) {
      setState(() {
        _unreadCount = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingL,
            vertical: AppConstants.spacingM,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfileHeaderCard(),
              const SizedBox(height: AppConstants.spacingXL),
              
              // General Settings
              SettingsSection(
                title: 'General Settings',
                children: [
                  SettingsItem(
                    title: 'Backup',
                    icon: Icons.cloud_outlined,
                    onTap: () {
                      // TODO: Implement backup functionality
                      logger.Logger.debug('Backup tapped');
                    },
                  ),
                  SettingsItem(
                    title: 'Biometrics',
                    icon: Icons.fingerprint_outlined,
                    onTap: () {
                      // TODO: Implement biometrics setup
                      logger.Logger.debug('Biometrics tapped');
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: AppConstants.spacingXL),
              
              // Legal
              SettingsSection(
                title: 'Legal',
                children: [
                  SettingsItem(
                    title: 'Privacy Policy',
                    icon: Icons.shield_outlined,
                    onTap: () {
                      // TODO: Navigate to privacy policy
                      logger.Logger.debug('Privacy Policy tapped');
                    },
                  ),
                  SettingsItem(
                    title: 'Terms and Conditions',
                    icon: Icons.shield_outlined,
                    onTap: () {
                      // TODO: Navigate to terms and conditions
                      logger.Logger.debug('Terms and Conditions tapped');
                    },
                  ),
                  SettingsItem(
                    title: 'Disclaimer',
                    icon: Icons.shield_outlined,
                    onTap: () {
                      // TODO: Navigate to disclaimer
                      logger.Logger.debug('Disclaimer tapped');
                    },
                  ),
                  SettingsItem(
                    title: 'Acceptable User Policy',
                    icon: Icons.shield_outlined,
                    onTap: () {
                      // TODO: Navigate to acceptable user policy
                      logger.Logger.debug('Acceptable User Policy tapped');
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: AppConstants.spacingXL),
              
              // Account Actions
              SettingsSection(
                title: '',
                children: [
                  SettingsItem(
                    title: 'Log Out',
                    icon: Icons.logout_outlined,
                    textColor: AppTheme.errorColor,
                    iconColor: AppTheme.errorColor,
                    showDivider: false,
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: AppConstants.spacingM),
              
              SettingsSection(
                title: '',
                children: [
                  SettingsItem(
                    title: 'How to close your account?',
                    icon: Icons.help_outline,
                    showDivider: false,
                    onTap: () {
                      // TODO: Navigate to account closure guide
                      logger.Logger.debug('Close account guide tapped');
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: AppConstants.spacingXL),
              
              // App Version
              Center(
                child: Text(
                  'Version 4.4.0',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              
              const SizedBox(height: AppConstants.spacingL),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Profile',
        style: GoogleFonts.montserrat(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () async {
                // Navigate to notifications page
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => sl<NotificationsCubit>(),
                      child: const NotificationsPage(),
                    ),
                  ),
                );
                // Reload unread count when returning from notifications page
                _loadUnreadCount();
              },
              color: AppTheme.textPrimary,
            ),
            if (_unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: _unreadCount > 9 ? 4 : 6,
                    vertical: 2,
                  ),
                  decoration: const BoxDecoration(
                    color: AppTheme.errorColor,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Log Out',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to log out?',
              style: GoogleFonts.montserrat(),
            ),
            const SizedBox(height: AppConstants.spacingM),
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(
                  color: AppTheme.warningColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.warningColor,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.spacingS),
                  Expanded(
                    child: Text(
                      'Warning: All your data will be deleted as it is stored locally on this device.',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: AppTheme.warningColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _handleLogout(context),
            child: Text(
              'Log Out',
              style: GoogleFonts.montserrat(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    Navigator.pop(context); // Close dialog

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryGreen,
          ),
        ),
      );

    try {
      final userPreferencesService = sl<UserPreferencesService>();
      final insuranceRepository = sl<InsuranceRepository>();

      // Clear all insurance data
      await insuranceRepository.clearAll();
      logger.Logger.info('Insurance data cleared');

      // Reset to first launch state (clears user name and sets first launch flag)
      final success = await userPreferencesService.resetToFirstLaunch();
      
      if (!success) {
        throw const StorageException('Failed to reset app state');
      }

      logger.Logger.info('User logged out, app reset to first launch');

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Navigate to welcome page and clear navigation stack
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const ErrorBoundary(
              child: WelcomePage(),
            ),
          ),
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e, stackTrace) {
      logger.Logger.error(
        'Failed to logout',
        e,
        stackTrace,
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to log out. Please try again.',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

