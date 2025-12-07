import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/jewellery_image_helper.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../../domain/entities/jewellery.dart';

/// Jewellery card widget matching insurance/garage card design
class JewelleryCard extends StatelessWidget {
  final Jewellery jewellery;
  final VoidCallback? onTap;
  final VoidCallback? onAskAssistant;

  const JewelleryCard({
    super.key,
    required this.jewellery,
    this.onTap,
    this.onAskAssistant,
  });

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
                  imageUrl: jewellery.imageUrl ?? JewelleryImageHelper.getImagePath(jewellery.category),
                  onAskAssistant: onAskAssistant,
                ),
                _ContentSection(
                  jewellery: jewellery,
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
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppTheme.borderColor,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryGreen,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppTheme.borderColor,
          child: const Icon(
            Icons.diamond_outlined,
            size: 48,
            color: AppTheme.textSecondary,
          ),
        ),
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          logger.Logger.warning(
            'JewelleryCard: Failed to load image',
            error,
            stackTrace,
          );
          return Container(
            color: AppTheme.borderColor,
            child: const Icon(
              Icons.diamond_outlined,
              size: 48,
              color: AppTheme.textSecondary,
            ),
          );
        },
      );
    }
  }
}

/// "Ask Assistant" button
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

/// Content section with jewellery details
class _ContentSection extends StatelessWidget {
  final Jewellery jewellery;
  final DateFormat dateFormat;

  const _ContentSection({
    required this.jewellery,
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
            displayName: jewellery.displayName,
            category: jewellery.category,
          ),
          const SizedBox(height: AppConstants.spacingM),
          if (jewellery.weight != null || jewellery.purity != null) ...[
            _JewelleryDetails(
              weight: jewellery.weight,
              purity: jewellery.purity,
            ),
            const SizedBox(height: 6),
          ],
          if (jewellery.currentValue != null) ...[
            _CurrentValue(value: jewellery.currentValue!),
            const SizedBox(height: 6),
          ],
          if (jewellery.lastValuationDate != null)
            _ValuationDate(
              date: jewellery.lastValuationDate!,
              dateFormat: dateFormat,
              isOutdated: jewellery.isValuationOutdated,
            ),
        ],
      ),
    );
  }
}

/// Title row
class _TitleRow extends StatelessWidget {
  final String displayName;
  final String category;

  const _TitleRow({
    required this.displayName,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            displayName,
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
          category,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryGreen,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

/// Jewellery details (weight and purity)
class _JewelleryDetails extends StatelessWidget {
  final double? weight;
  final String? purity;

  const _JewelleryDetails({
    this.weight,
    this.purity,
  });

  @override
  Widget build(BuildContext context) {
    final details = <String>[];
    if (weight != null) {
      details.add('${weight}g');
    }
    if (purity != null) {
      details.add(purity!);
    }

    if (details.isEmpty) return const SizedBox.shrink();

    return Text(
      details.join(' • '),
      style: GoogleFonts.montserrat(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppTheme.textSecondary,
        letterSpacing: -0.2,
      ),
    );
  }
}

/// Current value display
class _CurrentValue extends StatelessWidget {
  final double value;

  const _CurrentValue({required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Value: ₹${value.toStringAsFixed(0)}',
      style: GoogleFonts.montserrat(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryGreen,
        letterSpacing: -0.2,
      ),
    );
  }
}

/// Valuation date display with outdated warning
class _ValuationDate extends StatelessWidget {
  final DateTime date;
  final DateFormat dateFormat;
  final bool isOutdated;

  const _ValuationDate({
    required this.date,
    required this.dateFormat,
    required this.isOutdated,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOutdated ? AppTheme.warningColor : AppTheme.textSecondary;

    return Row(
      children: [
        if (isOutdated) ...[
          const Icon(
            Icons.warning_amber_outlined,
            size: 14,
            color: AppTheme.warningColor,
          ),
          const SizedBox(width: 4),
        ],
        Text(
          'Valuation: ',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppTheme.textSecondary,
            letterSpacing: -0.2,
          ),
        ),
        Text(
          dateFormat.format(date),
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: isOutdated ? FontWeight.w600 : FontWeight.w400,
            color: color,
            letterSpacing: -0.2,
          ),
        ),
        if (isOutdated) ...[
          const SizedBox(width: 4),
          Text(
            '(Outdated)',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.warningColor,
            ),
          ),
        ],
      ],
    );
  }
}

