import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/garage_list_cubit.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/garage_selection_cubit.dart';
import '../bloc/garage_selection_state.dart';
import '../../../insurance/presentation/widgets/neumorphic_container.dart';
import '../../../insurance/presentation/widgets/step_indicator.dart';
import 'garage_details_page.dart';

/// Page for selecting garage category (Car/Bike) and registration number
/// Matches the design with step indicator and neumorphic selectors
class GarageSelectionPage extends StatelessWidget {
  const GarageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GarageSelectionCubit(),
      child: const _GarageSelectionView(),
    );
  }
}

class _GarageSelectionView extends StatelessWidget {
  const _GarageSelectionView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: BlocBuilder<GarageSelectionCubit, GarageSelectionState>(
        builder: (context, state) {
          final selectedCategory =
              state is GarageSelectionLoaded ? state.selectedCategory : null;
          final registrationNumber =
              state is GarageSelectionLoaded ? state.registrationNumber : null;
          final isAcknowledged =
              state is GarageSelectionLoaded ? state.isAcknowledged : false;
          final canContinue =
              state is GarageSelectionLoaded ? state.canContinue : false;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingL,
                vertical: AppConstants.spacingM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step 1: Select Insurance Category
                  _StepSection(
                    stepNumber: 1,
                    title: 'Select Insurance Category',
                    child: _CategorySelector(
                      selectedCategory: selectedCategory,
                      onCategorySelected: (category) {
                        context
                            .read<GarageSelectionCubit>()
                            .selectCategory(category);
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXL),
                  // Step 2: Vehicle Registration Number
                  _StepSection(
                    stepNumber: 2,
                    title: 'Vehicle Registration Number',
                    child: _RegistrationNumberInput(
                      registrationNumber: registrationNumber,
                      onRegistrationChanged: (value) {
                        context
                            .read<GarageSelectionCubit>()
                            .setRegistrationNumber(value);
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  // Disclaimer/Acknowledgement
                  _DisclaimerCheckbox(
                    isChecked: isAcknowledged,
                    onChanged: (value) {
                      context
                          .read<GarageSelectionCubit>()
                          .toggleAcknowledged();
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingXL),
                  // Continue Button
                  _ContinueButton(
                    enabled: canContinue,
                    onPressed: () {
                      final category = selectedCategory;
                      final regNumber = registrationNumber;
                      if (category != null && regNumber != null) {
                        // Check if GarageListCubit is available in the tree
                        GarageListCubit? garageListCubit;
                        try {
                          garageListCubit = context.read<GarageListCubit>();
                        } catch (e) {
                          // Cubit not available - this is okay
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => garageListCubit != null
                                ? BlocProvider.value(
                                    value: garageListCubit,
                                    child: GarageDetailsPage(
                                      vehicleType: category,
                                      registrationNumber: regNumber,
                                    ),
                                  )
                                : GarageDetailsPage(
                                    vehicleType: category,
                                    registrationNumber: regNumber,
                                  ),
                          ),
                        );
                      }
                    },
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
        'My Garage',
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

/// Category selector with neumorphic design (Car/Bike)
class _CategorySelector extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const _CategorySelector({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      borderRadius: 40,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingL,
      ),
      isSelected: selectedCategory != null,
      child: Row(
        children: [
          Expanded(
            child: _CategoryOption(
              label: 'Car',
              icon: Icons.directions_car,
              isSelected: selectedCategory == 'Car',
              onTap: () => onCategorySelected('Car'),
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: _CategoryOption(
              label: 'Bike',
              icon: Icons.two_wheeler,
              isSelected: selectedCategory == 'Bike',
              onTap: () => onCategorySelected('Bike'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual category option
class _CategoryOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryOption({
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
            width: 60,
            height: 60,
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
              size: 30,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? AppTheme.textPrimary
                  : AppTheme.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Registration number input
class _RegistrationNumberInput extends StatelessWidget {
  final String? registrationNumber;
  final ValueChanged<String> onRegistrationChanged;

  const _RegistrationNumberInput({
    required this.registrationNumber,
    required this.onRegistrationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      borderRadius: 40,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      isSelected: registrationNumber != null && registrationNumber!.isNotEmpty,
      child: TextField(
        controller: TextEditingController(
          text: registrationNumber,
        )..selection = TextSelection.fromPosition(
            TextPosition(offset: registrationNumber?.length ?? 0),
          ),
        onChanged: onRegistrationChanged,
        decoration: InputDecoration(
          hintText: 'RJ06SS2017',
          hintStyle: GoogleFonts.montserrat(
            color: AppTheme.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        style: GoogleFonts.montserrat(
          fontSize: 16,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}

/// Disclaimer checkbox
class _DisclaimerCheckbox extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const _DisclaimerCheckbox({
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (value) => onChanged(value ?? false),
          activeColor: AppTheme.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'I acknowledge that I am not impersonating another user / organization and that I will be solely liable for any legal consequences that might arise for accessing information pertaining to a different person / organization.',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Continue button with disabled state
class _ContinueButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onPressed;

  const _ContinueButton({
    required this.enabled,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: enabled ? AppTheme.primaryGreen : AppTheme.disabledButtonBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingM,
              ),
              child: Center(
                child: Text(
                  'Continue',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: enabled
                        ? Colors.white
                        : AppTheme.textSecondary.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

