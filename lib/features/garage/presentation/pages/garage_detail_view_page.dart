import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/garage_image_helper.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../bloc/garage_detail_cubit.dart';
import '../bloc/garage_detail_state.dart';
import '../../../insurance/presentation/pages/chatbot_page.dart';

/// Detail view page for a single garage/vehicle
/// Shows full image, details, and action buttons
class GarageDetailViewPage extends StatefulWidget {
  final String garageId;

  const GarageDetailViewPage({
    super.key,
    required this.garageId,
  });

  @override
  State<GarageDetailViewPage> createState() => _GarageDetailViewPageState();
}

class _GarageDetailViewPageState extends State<GarageDetailViewPage> {
  @override
  void initState() {
    super.initState();
    // Load garage when page opens
    context.read<GarageDetailCubit>().loadGarage(widget.garageId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: AppTheme.headerTextColor,
        ),
        title: Text(
          'Vehicle Details',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.headerTextColor,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: BlocBuilder<GarageDetailCubit, GarageDetailState>(
        builder: (context, state) {
          if (state is GarageDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              ),
            );
          }

          if (state is GarageDetailError) {
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
                      state.message,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spacingL),
                    ElevatedButton(
                      onPressed: () {
                        context.read<GarageDetailCubit>().retry(widget.garageId);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is GarageDetailLoaded) {
            return _buildContent(context, state.garage);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, garage) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full-width image
          _buildImage(garage.imageUrl ?? GarageImageHelper.getImagePath(garage.vehicleType)),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Registration Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        garage.make != null && garage.model != null
                            ? '${garage.make} ${garage.model}'
                            : garage.vehicleType,
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ),
                    Text(
                      garage.registrationNumber,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingM),
                // Vehicle Type Tag
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
                    garage.vehicleType,
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
                // Vehicle Details
                if (garage.year != null)
                  _buildDetailRow(context, 'Year', garage.year.toString()),
                if (garage.year != null) const SizedBox(height: AppConstants.spacingM),
                if (garage.color != null)
                  _buildDetailRow(context, 'Color', garage.color!),
                if (garage.color != null) const SizedBox(height: AppConstants.spacingM),
                if (garage.make != null)
                  _buildDetailRow(context, 'Make', garage.make!),
                if (garage.make != null) const SizedBox(height: AppConstants.spacingM),
                if (garage.model != null)
                  _buildDetailRow(context, 'Model', garage.model!),
                if (garage.model != null) const SizedBox(height: AppConstants.spacingL),
                // Insurance Details Section
                if (garage.insuranceProvider != null || garage.policyNumber != null)
                  const Divider(height: 1, thickness: 1, color: AppTheme.borderColor),
                if (garage.insuranceProvider != null || garage.policyNumber != null)
                  const SizedBox(height: AppConstants.spacingL),
                if (garage.insuranceProvider != null)
                  _buildDetailRow(context, 'Insurance Provider', garage.insuranceProvider!),
                if (garage.insuranceProvider != null) const SizedBox(height: AppConstants.spacingM),
                if (garage.policyNumber != null)
                  _buildDetailRow(context, 'Policy Number', garage.policyNumber!),
                if (garage.policyNumber != null) const SizedBox(height: AppConstants.spacingM),
                if (garage.insuranceStartDate != null)
                  _buildDetailRow(
                    context,
                    'Insurance Start Date',
                    dateFormat.format(garage.insuranceStartDate!),
                  ),
                if (garage.insuranceStartDate != null) const SizedBox(height: AppConstants.spacingM),
                if (garage.insuranceEndDate != null) ...[
                  _buildDetailRow(
                    context,
                    'Insurance End Date',
                    dateFormat.format(garage.insuranceEndDate!),
                  ),
                  if (garage.isInsuranceExpiringSoon || garage.isInsuranceExpired) ...[
                    const SizedBox(height: AppConstants.spacingS),
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingS),
                      decoration: BoxDecoration(
                        color: garage.isInsuranceExpired
                            ? Colors.red.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            garage.isInsuranceExpired
                                ? Icons.error_outline
                                : Icons.warning_outlined,
                            color: garage.isInsuranceExpired
                                ? Colors.red
                                : Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: AppConstants.spacingS),
                          Text(
                            garage.isInsuranceExpired
                                ? 'Insurance has expired'
                                : 'Insurance expiring soon',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: garage.isInsuranceExpired
                                  ? Colors.red
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                if (garage.notes != null && garage.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingL),
                  const Divider(height: 1, thickness: 1, color: AppTheme.borderColor),
                  const SizedBox(height: AppConstants.spacingL),
                  Text(
                    'Notes',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    garage.notes!,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: AppConstants.spacingXXL),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) => sl<GarageDetailCubit>(),
                                child: ChatbotPage(garage: garage),
                              ),
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
                          side: const BorderSide(color: AppTheme.primaryGreen),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: imageUrl.startsWith('http://') || imageUrl.startsWith('https://')
          ? CachedNetworkImage(
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
                  Icons.error_outline,
                  size: 48,
                  color: AppTheme.textSecondary,
                ),
              ),
            )
          : Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                logger.Logger.warning(
                  'GarageDetailViewPage: Failed to load image',
                  error,
                  stackTrace,
                );
                return Container(
                  color: AppTheme.borderColor,
                  child: const Icon(
                    Icons.directions_car,
                    size: 48,
                    color: AppTheme.textSecondary,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

