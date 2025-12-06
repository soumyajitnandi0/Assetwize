import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

/// Profile completion indicator widget
/// Shows circular progress with percentage
class ProfileCompletionIndicator extends StatelessWidget {
  final int completion;

  const ProfileCompletionIndicator({
    super.key,
    required this.completion,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Circular Progress Indicator
        SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: completion / 100,
                  strokeWidth: 6,
                  backgroundColor: AppTheme.borderColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryGreen,
                  ),
                ),
              ),
              // Percentage text
              Text(
                '$completion%',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        // Text
        Text(
          'Complete your profile',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

