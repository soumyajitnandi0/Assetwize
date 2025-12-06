import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/insurance_detail_cubit.dart';
import '../bloc/insurance_detail_state.dart';

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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                // Title and Provider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        insurance.title,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                    Text(
                      insurance.provider,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingM),
                // Type
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingM,
                    vertical: AppConstants.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreenLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Text(
                    insurance.type,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingL),
                // Divider
                const Divider(),
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
                if (insurance.shortDescription != null) ...[
                  const SizedBox(height: AppConstants.spacingL),
                  const Divider(),
                  const SizedBox(height: AppConstants.spacingL),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    insurance.shortDescription!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                if (insurance.metadata != null &&
                    insurance.metadata!.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingL),
                  const Divider(),
                  const SizedBox(height: AppConstants.spacingL),
                  Text(
                    'Additional Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  ...insurance.metadata!.entries.map(
                    (entry) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppConstants.spacingS),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              '${entry.key}:',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value.toString(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppConstants.spacingXXL),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement register/renew action
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Register/Renew action coming soon'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Register/Renew'),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingM),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement ask assistant action
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Ask Assistant for ${insurance.title}'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Ask Assistant'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryGreen,
                          side: const BorderSide(color: AppTheme.primaryGreen),
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

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  /// Builds the image widget, handling both asset and network images
  Widget _buildImage(String imageUrl) {
    // Check if it's a local asset path or network URL
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Log the error for debugging
          debugPrint('Failed to load asset: $imageUrl');
          debugPrint('Error: $error');
          return Container(
            height: 300,
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
            height: 300,
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
        height: 300,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 300,
          color: AppTheme.backgroundLight,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryGreen,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 300,
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
