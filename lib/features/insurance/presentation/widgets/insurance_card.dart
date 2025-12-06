import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/insurance.dart';

/// Optimized insurance card matching Figma design
/// Production-ready with performance optimizations and clean code
class InsuranceCard extends StatelessWidget {
  final Insurance insurance;
  final VoidCallback? onTap;
  final VoidCallback? onAskAssistant;

  const InsuranceCard({
    super.key,
    required this.insurance,
    this.onTap,
    this.onAskAssistant,
  });

  // Static formatter to avoid recreation on every build
  static final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingL,
        vertical: AppConstants.spacingS,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _ImageSection(
                  imageUrl: insurance.imageUrl,
                  onAskAssistant: onAskAssistant,
                ),
                _ContentSection(
                  insurance: insurance,
                  dateFormat: _dateFormat,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Image section with "Ask Assistant" button overlay
class _ImageSection extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onAskAssistant;

  const _ImageSection({
    required this.imageUrl,
    this.onAskAssistant,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(AppConstants.radiusXL),
        topRight: Radius.circular(AppConstants.radiusXL),
      ),
      child: SizedBox(
        height: AppConstants.cardImageHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(),
            if (onAskAssistant != null)
              Positioned(
                top: AppConstants.spacingM,
                right: AppConstants.spacingM,
                child: _AskAssistantButton(onTap: onAskAssistant),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    // Check if it's a local asset path or network URL
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Log the error for debugging
          debugPrint('Failed to load asset: $imageUrl');
          debugPrint('Error: $error');
          return const _ImageError();
        },
        // Add a placeholder while loading
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return const _ImagePlaceholder();
        },
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 200),
        memCacheHeight: 400, // Optimize memory usage
        maxHeightDiskCache: 800,
        placeholder: (_, __) => const _ImagePlaceholder(),
        errorWidget: (_, __, ___) => const _ImageError(),
      );
    }
  }
}

/// Loading placeholder for images
class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundLight,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.primaryGreen.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}

/// Error widget for failed image loads
class _ImageError extends StatelessWidget {
  const _ImageError();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 40,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Image unavailable',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Ask Assistant" button with glassmorphism effect
/// Rounded capsule button with white background and drop shadow
class _AskAssistantButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _AskAssistantButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  'Ask Assistant',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.2,
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

/// Content section with policy details
class _ContentSection extends StatelessWidget {
  final Insurance insurance;
  final DateFormat dateFormat;

  const _ContentSection({
    required this.insurance,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _TitleRow(
            title: insurance.title,
            provider: insurance.provider,
          ),
          const SizedBox(height: AppConstants.spacingM),
          _PolicyNumber(policyNumber: insurance.policyNumber),
          const SizedBox(height: 6),
          _EndDate(
            endDate: insurance.endDate,
            dateFormat: dateFormat,
            isExpiringSoon: insurance.isExpiringSoon,
          ),
        ],
      ),
    );
  }
}

/// Title and provider row
class _TitleRow extends StatelessWidget {
  final String title;
  final String provider;

  const _TitleRow({
    required this.title,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              height: 1.3,
              letterSpacing: -0.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          provider,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

/// Policy number display
class _PolicyNumber extends StatelessWidget {
  final String policyNumber;

  const _PolicyNumber({required this.policyNumber});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Policy # $policyNumber',
      style: GoogleFonts.montserrat(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppTheme.textSecondary,
        letterSpacing: -0.2,
      ),
    );
  }
}

/// End date display with expiry warning
class _EndDate extends StatelessWidget {
  final DateTime endDate;
  final DateFormat dateFormat;
  final bool isExpiringSoon;

  const _EndDate({
    required this.endDate,
    required this.dateFormat,
    required this.isExpiringSoon,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = endDate.isBefore(DateTime.now());
    final color = isExpired
        ? AppTheme.errorColor
        : isExpiringSoon
            ? AppTheme.warningColor
            : AppTheme.textSecondary;

    return Row(
      children: [
        if (isExpiringSoon || isExpired) ...[
          Icon(
            isExpired ? Icons.error_outline : Icons.warning_amber_outlined,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
        ],
        Text(
          'Ends on: ',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppTheme.textSecondary,
            letterSpacing: -0.2,
          ),
        ),
        Text(
          dateFormat.format(endDate),
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight:
                isExpiringSoon || isExpired ? FontWeight.w600 : FontWeight.w400,
            color: color,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
