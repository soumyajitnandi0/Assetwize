import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../notifications/domain/usecases/notify_asset_added.dart';
import '../../../../core/utils/garage_image_helper.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../../../insurance/presentation/pages/insurance_list_page.dart';
import '../../domain/entities/garage.dart';
import '../../domain/usecases/add_garage.dart';

/// Page for entering garage/vehicle details
/// Similar to insurance details form
class GarageDetailsPage extends StatefulWidget {
  final String vehicleType; // "Car" or "Bike"
  final String registrationNumber;

  const GarageDetailsPage({
    super.key,
    required this.vehicleType,
    required this.registrationNumber,
  });

  @override
  State<GarageDetailsPage> createState() => _GarageDetailsPageState();
}

class _GarageDetailsPageState extends State<GarageDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _insuranceProviderController = TextEditingController();
  final _policyNumberController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _insuranceStartDate;
  DateTime? _insuranceEndDate;

  bool _isLoading = false;

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _insuranceProviderController.dispose();
    _policyNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _insuranceStartDate = picked;
        } else {
          _insuranceEndDate = picked;
        }
      });
    }
  }

  Future<void> _saveGarage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final garage = Garage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        vehicleType: widget.vehicleType,
        registrationNumber: widget.registrationNumber,
        make: _makeController.text.trim().isEmpty
            ? null
            : _makeController.text.trim(),
        model: _modelController.text.trim().isEmpty
            ? null
            : _modelController.text.trim(),
        year: _yearController.text.trim().isEmpty
            ? null
            : int.tryParse(_yearController.text.trim()),
        color: _colorController.text.trim().isEmpty
            ? null
            : _colorController.text.trim(),
        insuranceProvider: _insuranceProviderController.text.trim().isEmpty
            ? null
            : _insuranceProviderController.text.trim(),
        policyNumber: _policyNumberController.text.trim().isEmpty
            ? null
            : _policyNumberController.text.trim(),
        insuranceStartDate: _insuranceStartDate,
        insuranceEndDate: _insuranceEndDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        imageUrl: GarageImageHelper.getImagePath(widget.vehicleType),
      );

      final addGarage = sl<AddGarage>();
      await addGarage(garage);

      // Create notification
      try {
        final notifyAssetAdded = sl<NotifyAssetAdded>();
        await notifyAssetAdded(
          'Vehicle',
          '${widget.vehicleType} - ${widget.registrationNumber}',
        );
        // Refresh unread count
        sl<NotificationService>().refreshUnreadCount();
      } catch (e, stackTrace) {
        // Log error but don't block the flow
        logger.Logger.warning('Failed to create notification for new vehicle', e, stackTrace);
      }

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.vehicleType} added successfully!',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: AppTheme.primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );

      // Pop all routes until we reach the main navigator (first route)
      Navigator.of(context).popUntil((route) => route.isFirst);
      
      // Switch to garage tab and refresh the list
      WidgetsBinding.instance.addPostFrameCallback((_) {
        InsuranceListPage.switchToGarageTab();
      });
    } catch (e, stackTrace) {
      logger.Logger.error(
        'GarageDetailsPage: Failed to save garage',
        e,
        stackTrace,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save vehicle: ${e.toString()}',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category and Registration Number (read-only)
              _buildInfoCard(),
              const SizedBox(height: AppConstants.spacingXL),

              // Vehicle Details Section
              Text(
                'Vehicle Details',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Make
              _buildTextField(
                controller: _makeController,
                label: 'Make',
                hint: 'e.g., Honda, Toyota',
                icon: Icons.branding_watermark,
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Model
              _buildTextField(
                controller: _modelController,
                label: 'Model',
                hint: 'e.g., Civic, City',
                icon: Icons.directions_car,
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Year
              _buildTextField(
                controller: _yearController,
                label: 'Year',
                hint: 'e.g., 2020',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final year = int.tryParse(value);
                    if (year == null || year < 1900 || year > 2030) {
                      return 'Please enter a valid year';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Color
              _buildTextField(
                controller: _colorController,
                label: 'Color',
                hint: 'e.g., Red, Blue',
                icon: Icons.palette,
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // Insurance Details Section
              Text(
                'Insurance Details (Optional)',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Insurance Provider
              _buildTextField(
                controller: _insuranceProviderController,
                label: 'Insurance Provider',
                hint: 'e.g., ICICI, HDFC',
                icon: Icons.business,
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Policy Number
              _buildTextField(
                controller: _policyNumberController,
                label: 'Policy Number',
                hint: 'Enter policy number',
                icon: Icons.description,
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Insurance Start Date
              _buildDateField(
                label: 'Insurance Start Date',
                date: _insuranceStartDate,
                onTap: () => _selectDate(context, true),
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Insurance End Date
              _buildDateField(
                label: 'Insurance End Date',
                date: _insuranceEndDate,
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // Notes
              _buildTextField(
                controller: _notesController,
                label: 'Notes (Optional)',
                hint: 'Additional notes about the vehicle',
                icon: Icons.note,
                maxLines: 3,
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveGarage,
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
                          'Save Vehicle',
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
            '${widget.vehicleType} - ${widget.registrationNumber}',
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
    String? Function(String?)? validator,
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
      validator: validator,
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

