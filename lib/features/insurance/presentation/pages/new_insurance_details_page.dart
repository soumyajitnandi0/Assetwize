import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/insurance_image_helper.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../../domain/entities/insurance.dart';
import '../../domain/repositories/insurance_repository.dart';
import '../../domain/usecases/add_insurance.dart';
import '../bloc/insurance_list_cubit.dart';

/// Page for entering insurance details
/// After filling, saves to SharedPreferences and shows in list
class NewInsuranceDetailsPage extends StatefulWidget {
  final String category;
  final String type;

  const NewInsuranceDetailsPage({
    super.key,
    required this.category,
    required this.type,
  });

  @override
  State<NewInsuranceDetailsPage> createState() =>
      _NewInsuranceDetailsPageState();
}

class _NewInsuranceDetailsPageState extends State<NewInsuranceDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _providerController = TextEditingController();
  final _policyNumberController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _providerController.dispose();
    _policyNumberController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    bool isStartDate,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveInsurance() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both start and end dates'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Store context-dependent values before async operation
    final repository = sl<InsuranceRepository>();
    final listCubit = context.read<InsuranceListCubit>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final addInsuranceUseCase = AddInsurance(repository);

      // Get image path based on insurance type
      final imagePath = InsuranceImageHelper.getImagePath(widget.type);

      final insurance = Insurance(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        provider: _providerController.text.trim(),
        policyNumber: _policyNumberController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        imageUrl: imagePath,
        shortDescription: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        type: '${widget.category} - ${widget.type}',
        metadata: {
          'category': widget.category,
          'type': widget.type,
        },
      );

      await addInsuranceUseCase(insurance);

      // Create notification for new asset added
      try {
        final notificationService = sl<NotificationService>();
        await notificationService.notifyAssetAdded(
          'Insurance',
          _titleController.text.trim(),
        );
      } catch (e, stackTrace) {
        // Log error but don't block the flow
        logger.Logger.warning('Failed to create notification for new asset', e, stackTrace);
      }

      // Refresh the list and navigate back
      if (mounted) {
        listCubit.loadInsurances();
        navigator.popUntil((route) => route.isFirst);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Insurance added successfully!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error saving insurance: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insurance Details'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category and Type display
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(width: AppConstants.spacingS),
                    Expanded(
                      child: Text(
                        '${widget.category} - ${widget.type}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingXL),
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Insurance Title *',
                  hintText: 'e.g., Home Insurance',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter insurance title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingM),
              // Provider
              TextFormField(
                controller: _providerController,
                decoration: const InputDecoration(
                  labelText: 'Provider *',
                  hintText: 'e.g., ICICI, HDFC',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter provider name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingM),
              // Policy Number
              TextFormField(
                controller: _policyNumberController,
                decoration: const InputDecoration(
                  labelText: 'Policy Number *',
                  hintText: 'e.g., 4395654698345',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter policy number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingM),
              // Start Date
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Date *',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _startDate != null
                        ? dateFormat.format(_startDate!)
                        : 'Select start date',
                    style: TextStyle(
                      color: _startDate != null
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),
              // End Date
              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'End Date *',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _endDate != null
                        ? dateFormat.format(_endDate!)
                        : 'Select end date',
                    style: TextStyle(
                      color: _endDate != null
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Additional details (optional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: AppConstants.spacingXL),
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveInsurance,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacingM,
                    ),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Insurance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
