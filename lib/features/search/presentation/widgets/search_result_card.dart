import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../../../../core/utils/garage_image_helper.dart';
import '../../../../core/utils/jewellery_image_helper.dart';
import '../../../../core/utils/realty_image_helper.dart';
import '../../../../core/utils/insurance_image_helper.dart';
import '../../domain/entities/search_result.dart';

/// Unified search result card that displays any asset type
class SearchResultCard extends StatelessWidget {
  final SearchResult result;
  final VoidCallback? onTap;
  final VoidCallback? onAskAssistant;

  const SearchResultCard({
    super.key,
    required this.result,
    this.onTap,
    this.onAskAssistant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  imageUrl: result.imageUrl ?? _getDefaultImagePath(result.assetType, result.metadata),
                  assetType: result.assetType,
                  onAskAssistant: onAskAssistant,
                ),
                _ContentSection(result: result),
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
  final String? imageUrl;
  final AssetType assetType;
  final VoidCallback? onAskAssistant;

  const _ImageSection({
    this.imageUrl,
    required this.assetType,
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
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        color: AppTheme.borderColor,
        child: Icon(
          _getDefaultIcon(),
          size: 48,
          color: AppTheme.textSecondary,
        ),
      );
    }

    // Check if it's a local asset path or network URL
    if (imageUrl!.startsWith('assets/')) {
      return Image.asset(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          logger.Logger.warning(
            'SearchResultCard: Failed to load asset image',
            error,
            stackTrace,
          );
          return Container(
            color: AppTheme.borderColor,
            child: Icon(
              _getDefaultIcon(),
              size: 48,
              color: AppTheme.textSecondary,
            ),
          );
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return Container(
            color: AppTheme.borderColor,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    } else if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppTheme.borderColor,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryGreen,
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          logger.Logger.warning(
            'SearchResultCard: Failed to load network image',
            error,
            null,
          );
          return Container(
            color: AppTheme.borderColor,
            child: Icon(
              _getDefaultIcon(),
              size: 48,
              color: AppTheme.textSecondary,
            ),
          );
        },
      );
    } else {
      // Fallback: try as asset path anyway
      return Image.asset(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          logger.Logger.warning(
            'SearchResultCard: Failed to load image (unknown format)',
            error,
            stackTrace,
          );
          return Container(
            color: AppTheme.borderColor,
            child: Icon(
              _getDefaultIcon(),
              size: 48,
              color: AppTheme.textSecondary,
            ),
          );
        },
      );
    }
  }

  IconData _getDefaultIcon() {
    switch (assetType) {
      case AssetType.insurance:
        return Icons.shield_outlined;
      case AssetType.garage:
        return Icons.directions_car_outlined;
      case AssetType.jewellery:
        return Icons.diamond_outlined;
      case AssetType.realty:
        return Icons.home_outlined;
    }
  }
}

/// Helper method to get default image path based on asset type and metadata
String? _getDefaultImagePath(AssetType assetType, Map<String, dynamic>? metadata) {
  if (metadata == null) return null;
  
  try {
    switch (assetType) {
      case AssetType.insurance:
        final insurance = metadata['insurance'];
        if (insurance != null) {
          // Extract type from insurance.type (format: "Category - Type")
          final typeString = insurance.type?.toString() ?? '';
          if (typeString.isNotEmpty) {
            final parts = typeString.split(' - ');
            if (parts.length >= 2) {
              return InsuranceImageHelper.getImagePath(parts[1].trim());
            } else if (parts.length == 1) {
              return InsuranceImageHelper.getImagePath(parts[0].trim());
            }
          }
        }
        return null;
      case AssetType.garage:
        final garage = metadata['garage'];
        if (garage != null) {
          final vehicleType = garage.vehicleType?.toString() ?? '';
          if (vehicleType.isNotEmpty) {
            return GarageImageHelper.getImagePath(vehicleType);
          }
        }
        return null;
      case AssetType.jewellery:
        final jewellery = metadata['jewellery'];
        if (jewellery != null) {
          final category = jewellery.category?.toString() ?? '';
          if (category.isNotEmpty) {
            return JewelleryImageHelper.getImagePath(category);
          }
        }
        return null;
      case AssetType.realty:
        final realty = metadata['realty'];
        if (realty != null) {
          final propertyType = realty.propertyType?.toString() ?? '';
          if (propertyType.isNotEmpty) {
            return RealtyImageHelper.getImagePath(propertyType);
          }
        }
        return null;
    }
  } catch (e, stackTrace) {
    logger.Logger.warning('Failed to get default image path', e, stackTrace);
    return null;
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

/// Content section with asset details
class _ContentSection extends StatelessWidget {
  final SearchResult result;

  const _ContentSection({required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  result.title,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingS,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getAssetTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Text(
                  _getAssetTypeLabel(),
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getAssetTypeColor(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            result.subtitle,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
              letterSpacing: -0.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getAssetTypeLabel() {
    switch (result.assetType) {
      case AssetType.insurance:
        return 'Insurance';
      case AssetType.garage:
        return 'Vehicle';
      case AssetType.jewellery:
        return 'Jewellery';
      case AssetType.realty:
        return 'Property';
    }
  }

  Color _getAssetTypeColor() {
    switch (result.assetType) {
      case AssetType.insurance:
        return AppTheme.primaryGreen;
      case AssetType.garage:
        return Colors.blue;
      case AssetType.jewellery:
        return Colors.amber;
      case AssetType.realty:
        return Colors.purple;
    }
  }
}

