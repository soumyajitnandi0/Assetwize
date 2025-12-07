import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../bloc/insurance_detail_cubit.dart';
import '../bloc/insurance_detail_state.dart';
import 'chatbot_page.dart';

/// Detail page for a single insurance policy
/// Shows full image, details, and action buttons
class InsuranceDetailPage extends StatefulWidget {
  final String insuranceId;

  const InsuranceDetailPage({
    super.key,
    required this.insuranceId,
  });

  @override
  State<InsuranceDetailPage> createState() => _InsuranceDetailPageState();
}

class _InsuranceDetailPageState extends State<InsuranceDetailPage> {
  @override
  void initState() {
    super.initState();
    // Load insurance when page opens
    context.read<InsuranceDetailCubit>().loadInsurance(widget.insuranceId);
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
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<InsuranceDetailCubit, InsuranceDetailState>(
        builder: (context, state) {
          if (state is InsuranceDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is InsuranceDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<InsuranceDetailCubit>()
                          .retry(widget.insuranceId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is InsuranceDetailLoaded) {
            return _buildContent(context, state.insurance);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, insurance) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    // Extract category and type from insurance.type or metadata
    final categoryType = _extractCategoryAndType(insurance);
    final category = categoryType['category'] ?? '';
    final type = categoryType['type'] ?? insurance.type;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full-width image
          _buildImage(insurance.imageUrl),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Provider Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        insurance.title,
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ),
                    Text(
                      insurance.provider,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingM),
                // Category - Type Tag (Light green pill)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingM,
                    vertical: AppConstants.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreenLight.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                  ),
                  child: Text(
                    category.isNotEmpty ? '$category - $type' : type,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingL),
                // Divider
                const Divider(height: 1, thickness: 1, color: AppTheme.borderColor),
                const SizedBox(height: AppConstants.spacingL),
                // Policy Details
                _buildDetailRow(
                  context,
                  'Policy Number',
                  insurance.policyNumber,
                ),
                const SizedBox(height: AppConstants.spacingM),
                _buildDetailRow(
                  context,
                  'Start Date',
                  dateFormat.format(insurance.startDate),
                ),
                const SizedBox(height: AppConstants.spacingM),
                _buildDetailRow(
                  context,
                  'End Date',
                  dateFormat.format(insurance.endDate),
                ),
                if (insurance.coverage != null && insurance.coverage!.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingM),
                  _buildDetailRow(
                    context,
                    'Coverage',
                    insurance.coverage!,
                  ),
                ],
                const SizedBox(height: AppConstants.spacingL),
                // Divider
                const Divider(height: 1, thickness: 1, color: AppTheme.borderColor),
                const SizedBox(height: AppConstants.spacingL),
                // Additional Information
                Text(
                  'Additional Information',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingS),
                if (category.isNotEmpty)
                  _buildAdditionalInfoRow(context, 'category:', category),
                _buildAdditionalInfoRow(context, 'type:', type),
                const SizedBox(height: AppConstants.spacingXXL),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Register/Renew action coming soon'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        label: Text(
                          'Register/Renew',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentYellow,
                          foregroundColor: AppTheme.textPrimary,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.spacingM,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingM),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatbotPage(insurance: insurance),
                            ),
                          );
                        },
                        icon: const Icon(Icons.auto_awesome),
                        label: Text(
                          'Ask Assistant',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryGreen,
                          side: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.spacingM,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingXL),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Extracts category and type from insurance type string or metadata
  Map<String, String> _extractCategoryAndType(dynamic insurance) {
    // Check metadata first
    if (insurance.metadata != null) {
      final category = insurance.metadata!['category']?.toString() ?? '';
      final type = insurance.metadata!['type']?.toString() ?? '';
      if (category.isNotEmpty && type.isNotEmpty) {
        return {'category': category, 'type': type};
      }
    }

    // Try to parse from type string (format: "Category - Type")
    final typeString = insurance.type.toString();
    if (typeString.contains(' - ')) {
      final parts = typeString.split(' - ');
      if (parts.length == 2) {
        return {
          'category': parts[0].trim(),
          'type': parts[1].trim(),
        };
      }
    }

    // Default: return type only
    return {'category': '', 'type': typeString};
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the image widget, handling both asset and network images
  Widget _buildImage(String imageUrl) {
    // Check if it's a local asset path or network URL
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Log the error for debugging
          logger.Logger.warning('Failed to load asset image', error, stackTrace);
          return Container(
            height: 250,
            color: AppTheme.backgroundLight,
            child: const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: AppTheme.textSecondary,
              ),
            ),
          );
        },
        // Add a placeholder while loading
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return Container(
            height: 250,
            color: AppTheme.backgroundLight,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              ),
            ),
          );
        },
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 250,
          color: AppTheme.backgroundLight,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryGreen,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 250,
          color: AppTheme.backgroundLight,
          child: const Center(
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      );
    }
  }
}
