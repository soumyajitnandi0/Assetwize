import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../notifications/domain/usecases/notify_asset_added.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../../../insurance/presentation/pages/insurance_list_page.dart';
import '../../domain/entities/jewellery.dart';
import '../../domain/usecases/add_jewellery.dart';

/// Page for entering jewellery details
class JewelleryDetailsPage extends StatefulWidget {
  final String category; // "Gold", "Silver", "Diamond", "Platinum"
  final String itemName;

  const JewelleryDetailsPage({
    super.key,
    required this.category,
    required this.itemName,
  });

  @override
  State<JewelleryDetailsPage> createState() => _JewelleryDetailsPageState();
}

class _JewelleryDetailsPageState extends State<JewelleryDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _weightController = TextEditingController();
  final _purityController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _purchaseLocationController = TextEditingController();
  final _currentValueController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _purchaseDate;
  DateTime? _lastValuationDate;

  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _weightController.dispose();
    _purityController.dispose();
    _purchasePriceController.dispose();
    _purchaseLocationController.dispose();
    _currentValueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isPurchaseDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isPurchaseDate) {
          _purchaseDate = picked;
        } else {
          _lastValuationDate = picked;
        }
      });
    }
  }

  Future<void> _saveJewellery() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final jewellery = Jewellery(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: widget.category,
        itemName: widget.itemName,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        weight: _weightController.text.trim().isEmpty
            ? null
            : double.tryParse(_weightController.text.trim()),
        purity: _purityController.text.trim().isEmpty
            ? null
            : _purityController.text.trim(),
        purchasePrice: _purchasePriceController.text.trim().isEmpty
            ? null
            : double.tryParse(_purchasePriceController.text.trim()),
        purchaseDate: _purchaseDate,
        purchaseLocation: _purchaseLocationController.text.trim().isEmpty
            ? null
            : _purchaseLocationController.text.trim(),
        currentValue: _currentValueController.text.trim().isEmpty
            ? null
            : double.tryParse(_currentValueController.text.trim()),
        lastValuationDate: _lastValuationDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      final addJewellery = sl<AddJewellery>();
      await addJewellery(jewellery);

      // Create notification
      try {
        final notifyAssetAdded = sl<NotifyAssetAdded>();
        await notifyAssetAdded(
          'Jewellery',
          '${widget.category} ${widget.itemName}',
        );
        sl<NotificationService>().refreshUnreadCount();
      } catch (e, stackTrace) {
        logger.Logger.warning('Failed to create notification for new jewellery', e, stackTrace);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Jewellery added successfully!',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: AppTheme.primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          InsuranceListPage.switchToJewelleryTab();
        }
      });
    } catch (e, stackTrace) {
      logger.Logger.error(
        'JewelleryDetailsPage: Failed to save jewellery',
        e,
        stackTrace,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save jewellery: ${e.toString()}',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: AppConstants.spacingXL),
              Text(
                'Item Details',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                hint: 'e.g., Gold necklace with pendant',
                icon: Icons.description,
                maxLines: 2,
              ),
              const SizedBox(height: AppConstants.spacingM),
              _buildTextField(
                controller: _weightController,
                label: 'Weight (grams)',
                hint: 'e.g., 50.5',
                icon: Icons.scale,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppConstants.spacingM),
              _buildTextField(
                controller: _purityController,
                label: 'Purity',
                hint: 'e.g., 22K, 24K, 925',
                icon: Icons.star,
              ),
              const SizedBox(height: AppConstants.spacingXL),
              Text(
                'Purchase Information (Optional)',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),
              _buildTextField(
                controller: _purchasePriceController,
                label: 'Purchase Price',
                hint: 'e.g., 50000',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppConstants.spacingM),
              _buildDateField(
                label: 'Purchase Date',
                date: _purchaseDate,
                onTap: () => _selectDate(context, true),
              ),
              const SizedBox(height: AppConstants.spacingM),
              _buildTextField(
                controller: _purchaseLocationController,
                label: 'Purchase Location',
                hint: 'e.g., Tanishq, Malabar Gold',
                icon: Icons.location_on,
              ),
              const SizedBox(height: AppConstants.spacingXL),
              Text(
                'Valuation (Optional)',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),
              _buildTextField(
                controller: _currentValueController,
                label: 'Current Value',
                hint: 'e.g., 75000',
                icon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppConstants.spacingM),
              _buildDateField(
                label: 'Last Valuation Date',
                date: _lastValuationDate,
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: AppConstants.spacingXL),
              _buildTextField(
                controller: _notesController,
                label: 'Notes (Optional)',
                hint: 'Additional notes about the jewellery',
                icon: Icons.note,
                maxLines: 3,
              ),
              const SizedBox(height: AppConstants.spacingXL),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveJewellery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Save Jewellery',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: AppTheme.primaryGreen,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppTheme.primaryGreen,
            size: 20,
          ),
          const SizedBox(width: AppConstants.spacingS),
          Text(
            '${widget.category} - ${widget.itemName}',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(
            color: AppTheme.primaryGreen,
            width: 2,
          ),
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.montserrat(),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            borderSide: const BorderSide(color: AppTheme.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            borderSide: const BorderSide(
              color: AppTheme.primaryGreen,
              width: 2,
            ),
          ),
        ),
        child: Text(
          date != null
              ? DateFormat('dd/MM/yyyy').format(date)
              : 'Select date',
          style: GoogleFonts.montserrat(
            color: date != null
                ? AppTheme.textPrimary
                : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

