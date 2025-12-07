import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../notifications/domain/usecases/notify_asset_added.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../../../../core/utils/realty_image_helper.dart';
import '../../../insurance/presentation/pages/insurance_list_page.dart';
import '../../domain/entities/realty.dart';
import '../../domain/usecases/add_realty.dart';

/// Page for entering realty property details
class RealtyDetailsPage extends StatefulWidget {
  final String propertyType; // "House", "Apartment", "Land", "Commercial"
  final String address;

  const RealtyDetailsPage({
    super.key,
    required this.propertyType,
    required this.address,
  });

  @override
  State<RealtyDetailsPage> createState() => _RealtyDetailsPageState();
}

class _RealtyDetailsPageState extends State<RealtyDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _areaController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _currentValueController = TextEditingController();
  final _propertyNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  String? _areaUnit;
  DateTime? _purchaseDate;
  DateTime? _lastValuationDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _areaUnit = 'sqft'; // Default
  }

  @override
  void dispose() {
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _areaController.dispose();
    _purchasePriceController.dispose();
    _currentValueController.dispose();
    _propertyNumberController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isPurchaseDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: isPurchaseDate ? DateTime.now() : DateTime(2030),
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

  Future<void> _saveRealty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final realty = Realty(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        propertyType: widget.propertyType,
        address: widget.address,
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        state: _stateController.text.trim().isEmpty
            ? null
            : _stateController.text.trim(),
        zipCode: _zipCodeController.text.trim().isEmpty
            ? null
            : _zipCodeController.text.trim(),
        country: _countryController.text.trim().isEmpty
            ? null
            : _countryController.text.trim(),
        area: _areaController.text.trim().isEmpty
            ? null
            : double.tryParse(_areaController.text.trim()),
        areaUnit: _areaUnit,
        purchasePrice: _purchasePriceController.text.trim().isEmpty
            ? null
            : double.tryParse(_purchasePriceController.text.trim()),
        purchaseDate: _purchaseDate,
        currentValue: _currentValueController.text.trim().isEmpty
            ? null
            : double.tryParse(_currentValueController.text.trim()),
        lastValuationDate: _lastValuationDate,
        propertyNumber: _propertyNumberController.text.trim().isEmpty
            ? null
            : _propertyNumberController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        imageUrl: RealtyImageHelper.getImagePath(widget.propertyType),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      final addRealty = sl<AddRealty>();
      await addRealty(realty);

      // Create notification
      try {
        final notifyAssetAdded = sl<NotifyAssetAdded>();
        await notifyAssetAdded(
          'Realty',
          '${widget.propertyType} at ${widget.address}',
        );
        sl<NotificationService>().refreshUnreadCount();
      } catch (e, stackTrace) {
        logger.Logger.warning('Failed to create notification for new realty', e, stackTrace);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Property added successfully!',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: AppTheme.primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          InsuranceListPage.switchToRealtyTab();
        }
      });
    } catch (e, stackTrace) {
      logger.Logger.error(
        'RealtyDetailsPage: Failed to save realty',
        e,
        stackTrace,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save property: ${e.toString()}',
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
          'Property Details',
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
                'Location Details',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),
              _buildTextField(
                controller: _cityController,
                label: 'City',
                hint: 'e.g., Mumbai',
                icon: Icons.location_city,
              ),
              const SizedBox(height: AppConstants.spacingM),
              _buildTextField(
                controller: _stateController,
                label: 'State',
                hint: 'e.g., Maharashtra',
                icon: Icons.map,
              ),
              const SizedBox(height: AppConstants.spacingM),
              _buildTextField(
                controller: _zipCodeController,
                label: 'Zip Code',
                hint: 'e.g., 400001',
                icon: Icons.pin,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppConstants.spacingM),
              _buildTextField(
                controller: _countryController,
                label: 'Country',
                hint: 'e.g., India',
                icon: Icons.public,
              ),
              const SizedBox(height: AppConstants.spacingXL),
              Text(
                'Property Details',
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
                hint: 'e.g., 3 BHK apartment with balcony',
                icon: Icons.description,
                maxLines: 2,
              ),
              const SizedBox(height: AppConstants.spacingM),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildTextField(
                      controller: _areaController,
                      label: 'Area',
                      hint: 'e.g., 1200',
                      icon: Icons.square_foot,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _areaUnit,
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        prefixIcon: const Icon(Icons.straighten),
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
                      items: const [
                        DropdownMenuItem(value: 'sqft', child: Text('sqft')),
                        DropdownMenuItem(value: 'sqm', child: Text('sqm')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _areaUnit = value;
                        });
                      },
                      style: GoogleFonts.montserrat(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingM),
              _buildTextField(
                controller: _propertyNumberController,
                label: 'Property Number (Optional)',
                hint: 'e.g., Plot No. 123',
                icon: Icons.numbers,
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
                hint: 'e.g., 5000000',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppConstants.spacingM),
              _buildDateField(
                label: 'Purchase Date',
                date: _purchaseDate,
                onTap: () => _selectDate(context, true),
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
                hint: 'e.g., 7500000',
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
                hint: 'Additional notes about the property',
                icon: Icons.note,
                maxLines: 3,
              ),
              const SizedBox(height: AppConstants.spacingXL),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveRealty,
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
                          'Save Property',
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.propertyType} - ${widget.address}',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
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

