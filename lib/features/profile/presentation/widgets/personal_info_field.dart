import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

/// Personal info field widget
/// Displays label, value, and optional edit button
class PersonalInfoField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onEdit;
  final bool showEdit;

  const PersonalInfoField({
    super.key,
    required this.label,
    required this.value,
    this.onEdit,
    this.showEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingXS),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: value == 'Not set'
                      ? AppTheme.textSecondary
                      : AppTheme.textSecondary,
                ),
              ),
            ),
            if (showEdit && onEdit != null)
              GestureDetector(
                onTap: onEdit,
                child: Text(
                  'Edit',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryGreen,
                    decoration: TextDecoration.underline,
                    decorationColor: AppTheme.primaryGreen,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

