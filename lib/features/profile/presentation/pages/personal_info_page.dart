import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/logger.dart' as logger;
import '../../../../core/utils/validators.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_name.dart';
import '../../domain/usecases/update_phone_number.dart';
import '../../domain/usecases/update_email.dart';
import '../../../notifications/domain/usecases/notify_profile_updated.dart';
import '../widgets/profile_completion_indicator.dart';
import '../widgets/personal_info_field.dart';

/// Personal Info page
/// Displays and allows editing of user's personal information
class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  late final GetProfile _getProfile;
  late final UpdateName _updateName;
  late final UpdatePhoneNumber _updatePhoneNumber;
  late final UpdateEmail _updateEmail;
  late final NotifyProfileUpdated _notifyProfileUpdated;
  
  String _userName = '';
  String _phoneNumber = '';
  String _email = '';
  int _profileCompletion = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getProfile = sl<GetProfile>();
    _updateName = sl<UpdateName>();
    _updatePhoneNumber = sl<UpdatePhoneNumber>();
    _updateEmail = sl<UpdateEmail>();
    _notifyProfileUpdated = sl<NotifyProfileUpdated>();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final profile = await _getProfile();

      if (mounted) {
        setState(() {
          _userName = profile.name ?? '';
          _phoneNumber = profile.phoneNumber ?? '';
          _email = profile.email ?? '';
          _profileCompletion = profile.completionPercentage;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      logger.Logger.error('PersonalInfoPage: Failed to load profile', e, stackTrace);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  Future<void> _editName() async {
    if (!mounted) return;
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _EditDialog(
        title: 'Edit Name',
        initialValue: _userName,
        hint: 'Enter your name',
        validator: (value) => Validators.notEmpty(value, fieldName: 'Name'),
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await _updateName(result);
        
        // Create notification for profile update
        try {
          await _notifyProfileUpdated('Name');
        } catch (e, stackTrace) {
          logger.Logger.warning('Failed to create notification for profile update', e, stackTrace);
        }
        
        await _loadUserData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Name updated successfully'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update name: $errorMessage'),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _editPhoneNumber() async {
    if (!mounted) return;
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _EditDialog(
        title: 'Edit Phone Number',
        initialValue: _phoneNumber,
        hint: 'Enter your phone number',
        keyboardType: TextInputType.phone,
        validator: (value) => Validators.phoneNumber(value),
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await _updatePhoneNumber(result);
        
        // Create notification for profile update
        try {
          await _notifyProfileUpdated('Phone Number');
        } catch (e, stackTrace) {
          logger.Logger.warning('Failed to create notification for profile update', e, stackTrace);
        }
        
        await _loadUserData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number updated successfully'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update phone number: $errorMessage'),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _editEmail() async {
    if (!mounted) return;
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _EditDialog(
        title: 'Edit Email',
        initialValue: _email,
        hint: 'Enter your email',
        keyboardType: TextInputType.emailAddress,
        validator: (value) => Validators.email(value),
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await _updateEmail(result);
        
        // Create notification for profile update
        try {
          await _notifyProfileUpdated('Email');
        } catch (e, stackTrace) {
          logger.Logger.warning('Failed to create notification for profile update', e, stackTrace);
        }
        
        await _loadUserData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email updated successfully'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update email: $errorMessage'),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingL,
                vertical: AppConstants.spacingM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Completion Indicator
                  ProfileCompletionIndicator(
                    completion: _profileCompletion,
                  ),
                  const SizedBox(height: AppConstants.spacingXL),

                  // Profile Picture Section
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.borderColor,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(_userName),
                              style: GoogleFonts.montserrat(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXL),

                  // Personal Details Fields
                  PersonalInfoField(
                    label: 'Name',
                    value: _userName.isNotEmpty ? _userName : 'Not set',
                    onEdit: _editName,
                    showEdit: true,
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  PersonalInfoField(
                    label: 'Phone Number',
                    value: _phoneNumber.isNotEmpty ? _phoneNumber : 'Not set',
                    onEdit: _editPhoneNumber,
                    showEdit: true,
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  PersonalInfoField(
                    label: 'Email',
                    value: _email.isNotEmpty ? _email : 'Not set',
                    onEdit: _editEmail,
                    showEdit: true,
                  ),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
        color: AppTheme.textPrimary,
      ),
      title: Text(
        'Personal Info',
        style: GoogleFonts.montserrat(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }
}

/// Edit dialog for personal info fields
class _EditDialog extends StatefulWidget {
  final String title;
  final String initialValue;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _EditDialog({
    required this.title,
    required this.initialValue,
    required this.hint,
    this.keyboardType,
    this.validator,
  });

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hint,
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
          style: GoogleFonts.montserrat(),
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          autofocus: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.montserrat(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
          child: Text(
            'Save',
            style: GoogleFonts.montserrat(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

