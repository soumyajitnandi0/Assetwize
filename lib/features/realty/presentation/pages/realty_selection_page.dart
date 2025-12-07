import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/realty_selection_cubit.dart';
import '../bloc/realty_selection_state.dart';
import '../../../insurance/presentation/widgets/neumorphic_container.dart';
import '../../../insurance/presentation/widgets/step_indicator.dart';
import 'realty_details_page.dart';

/// Page for selecting property type and address
class RealtySelectionPage extends StatelessWidget {
  const RealtySelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RealtySelectionCubit(),
      child: const _RealtySelectionView(),
    );
  }
}

class _RealtySelectionView extends StatelessWidget {
  const _RealtySelectionView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: BlocBuilder<RealtySelectionCubit, RealtySelectionState>(
        builder: (context, state) {
          final selectedPropertyType =
              state is RealtySelectionLoaded ? state.selectedPropertyType : null;
          final address =
              state is RealtySelectionLoaded ? state.address : null;
          final isAcknowledged =
              state is RealtySelectionLoaded ? state.isAcknowledged : false;
          final canContinue =
              state is RealtySelectionLoaded ? state.canContinue : false;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingL,
                vertical: AppConstants.spacingM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step 1: Select Property Type
                  _StepSection(
                    stepNumber: 1,
                    title: 'Select Property Type',
                    child: _PropertyTypeSelector(
                      selectedPropertyType: selectedPropertyType,
                      onPropertyTypeSelected: (type) {
                        context
                            .read<RealtySelectionCubit>()
                            .selectPropertyType(type);
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXL),
                  // Step 2: Address
                  _StepSection(
                    stepNumber: 2,
                    title: 'Property Address',
                    child: _AddressInput(
                      address: address,
                      onAddressChanged: (value) {
                        context
                            .read<RealtySelectionCubit>()
                            .setAddress(value);
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXL),
                  // Disclaimer
                  _DisclaimerCheckbox(
                    isAcknowledged: isAcknowledged,
                    onChanged: (value) {
                      context
                          .read<RealtySelectionCubit>()
                          .setAcknowledged(value);
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingXL),
                  // Continue Button
                  _ContinueButton(
                    canContinue: canContinue,
                    onPressed: canContinue
                        ? () {
                            final propertyType = selectedPropertyType;
                            final addr = address;
                            if (propertyType != null && addr != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RealtyDetailsPage(
                                    propertyType: propertyType,
                                    address: addr,
                                  ),
                                ),
                              );
                            }
                          }
                        : null,
                  ),
                  const SizedBox(height: AppConstants.spacingL),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
        color: AppTheme.headerTextColor,
      ),
      title: Text(
        'My Realty',
        style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppTheme.headerTextColor,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.black.withOpacity(0.1),
        ),
      ),
    );
  }
}

/// Step section with indicator and title
class _StepSection extends StatelessWidget {
  final int stepNumber;
  final String title;
  final Widget child;

  const _StepSection({
    required this.stepNumber,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: StepIndicator(
            currentStep: stepNumber,
            totalSteps: 2,
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$stepNumber. $title',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.headerTextColor,
                ),
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ],
    );
  }
}

/// Property type selector with neumorphic design
class _PropertyTypeSelector extends StatelessWidget {
  final String? selectedPropertyType;
  final ValueChanged<String> onPropertyTypeSelected;

  const _PropertyTypeSelector({
    required this.selectedPropertyType,
    required this.onPropertyTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      borderRadius: 40,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingL,
      ),
      isSelected: selectedPropertyType != null,
      child: Row(
        children: [
          Expanded(
            child: _PropertyTypeOption(
              label: 'House',
              icon: Icons.home,
              isSelected: selectedPropertyType == 'House',
              onTap: () => onPropertyTypeSelected('House'),
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: _PropertyTypeOption(
              label: 'Apartment',
              icon: Icons.apartment,
              isSelected: selectedPropertyType == 'Apartment',
              onTap: () => onPropertyTypeSelected('Apartment'),
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: _PropertyTypeOption(
              label: 'Land',
              icon: Icons.landscape,
              isSelected: selectedPropertyType == 'Land',
              onTap: () => onPropertyTypeSelected('Land'),
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: _PropertyTypeOption(
              label: 'Commercial',
              icon: Icons.business,
              isSelected: selectedPropertyType == 'Commercial',
              onTap: () => onPropertyTypeSelected('Commercial'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual property type option
class _PropertyTypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PropertyTypeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryGreen.withOpacity(0.1)
                  : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryGreen
                  : AppTheme.textSecondary.withOpacity(0.5),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              softWrap: false,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Address input field
class _AddressInput extends StatelessWidget {
  final String? address;
  final ValueChanged<String> onAddressChanged;

  const _AddressInput({
    required this.address,
    required this.onAddressChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      isSelected: address != null && address!.isNotEmpty,
      child: TextField(
        onChanged: onAddressChanged,
        decoration: InputDecoration(
          hintText: 'e.g., 123 Main Street, City',
          border: InputBorder.none,
          hintStyle: GoogleFonts.montserrat(
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
        ),
        style: GoogleFonts.montserrat(
          color: AppTheme.textPrimary,
        ),
        maxLines: 2,
      ),
    );
  }
}

/// Disclaimer checkbox
class _DisclaimerCheckbox extends StatelessWidget {
  final bool isAcknowledged;
  final ValueChanged<bool> onChanged;

  const _DisclaimerCheckbox({
    required this.isAcknowledged,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: isAcknowledged,
          onChanged: (value) => onChanged(value ?? false),
          activeColor: AppTheme.primaryGreen,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'I acknowledge that the information provided is accurate',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Continue button
class _ContinueButton extends StatelessWidget {
  final bool canContinue;
  final VoidCallback? onPressed;

  const _ContinueButton({
    required this.canContinue,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        color: canContinue
            ? AppTheme.primaryGreen
            : AppTheme.borderColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          child: Center(
            child: Text(
              'Continue',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: canContinue ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

