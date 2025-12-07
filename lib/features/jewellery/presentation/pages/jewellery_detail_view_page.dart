import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/jewellery_image_helper.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../bloc/jewellery_detail_cubit.dart';
import '../bloc/jewellery_detail_state.dart';
import '../../../insurance/presentation/pages/chatbot_page.dart';

/// Detail view page for a single jewellery item
class JewelleryDetailViewPage extends StatefulWidget {
  final String jewelleryId;

  const JewelleryDetailViewPage({
    super.key,
    required this.jewelleryId,
  });

  @override
  State<JewelleryDetailViewPage> createState() => _JewelleryDetailViewPageState();
}

class _JewelleryDetailViewPageState extends State<JewelleryDetailViewPage> {
  @override
  void initState() {
    super.initState();
    context.read<JewelleryDetailCubit>().loadJewellery(widget.jewelleryId);
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
          'Jewellery Details',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.headerTextColor,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: BlocBuilder<JewelleryDetailCubit, JewelleryDetailState>(
        builder: (context, state) {
          if (state is JewelleryDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              ),
            );
          }

          if (state is JewelleryDetailError) {
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
                        context.read<JewelleryDetailCubit>().retry(widget.jewelleryId);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is JewelleryDetailLoaded) {
            return _buildContent(context, state.jewellery);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, jewellery) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(jewellery.imageUrl ?? JewelleryImageHelper.getImagePath(jewellery.category)),
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        jewellery.displayName,
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ),
                    Text(
                      jewellery.category,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingM),
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
                    jewellery.itemName,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingL),
                const Divider(height: 1, thickness: 1, color: AppTheme.borderColor),
                const SizedBox(height: AppConstants.spacingL),
                if (jewellery.weight != null)
                  _buildDetailRow(context, 'Weight', '${jewellery.weight}g'),
                if (jewellery.weight != null) const SizedBox(height: AppConstants.spacingM),
                if (jewellery.purity != null)
                  _buildDetailRow(context, 'Purity', jewellery.purity!),
                if (jewellery.purity != null) const SizedBox(height: AppConstants.spacingL),
                if (jewellery.purchasePrice != null || jewellery.purchaseDate != null || jewellery.purchaseLocation != null)
                  const Divider(height: 1, thickness: 1, color: AppTheme.borderColor),
                if (jewellery.purchasePrice != null || jewellery.purchaseDate != null || jewellery.purchaseLocation != null)
                  const SizedBox(height: AppConstants.spacingL),
                if (jewellery.purchasePrice != null)
                  _buildDetailRow(context, 'Purchase Price', '₹${jewellery.purchasePrice!.toStringAsFixed(0)}'),
                if (jewellery.purchasePrice != null) const SizedBox(height: AppConstants.spacingM),
                if (jewellery.purchaseDate != null)
                  _buildDetailRow(context, 'Purchase Date', dateFormat.format(jewellery.purchaseDate!)),
                if (jewellery.purchaseDate != null) const SizedBox(height: AppConstants.spacingM),
                if (jewellery.purchaseLocation != null)
                  _buildDetailRow(context, 'Purchase Location', jewellery.purchaseLocation!),
                if (jewellery.purchaseLocation != null) const SizedBox(height: AppConstants.spacingL),
                if (jewellery.currentValue != null || jewellery.lastValuationDate != null)
                  const Divider(height: 1, thickness: 1, color: AppTheme.borderColor),
                if (jewellery.currentValue != null || jewellery.lastValuationDate != null)
                  const SizedBox(height: AppConstants.spacingL),
                if (jewellery.currentValue != null)
                  _buildDetailRow(context, 'Current Value', '₹${jewellery.currentValue!.toStringAsFixed(0)}'),
                if (jewellery.currentValue != null) const SizedBox(height: AppConstants.spacingM),
                if (jewellery.lastValuationDate != null) ...[
                  _buildDetailRow(
                    context,
                    'Last Valuation Date',
                    dateFormat.format(jewellery.lastValuationDate!),
                  ),
                  if (jewellery.isValuationOutdated) ...[
                    const SizedBox(height: AppConstants.spacingS),
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingS),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_outlined,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: AppConstants.spacingS),
                          Text(
                            'Valuation is outdated (older than 1 year)',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                if (jewellery.notes != null && jewellery.notes!.isNotEmpty) ...[
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
                    jewellery.notes!,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: AppConstants.spacingXXL),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) => sl<JewelleryDetailCubit>(),
                                child: ChatbotPage(jewellery: jewellery),
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
                  Icons.diamond_outlined,
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
                  'JewelleryDetailViewPage: Failed to load image',
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

