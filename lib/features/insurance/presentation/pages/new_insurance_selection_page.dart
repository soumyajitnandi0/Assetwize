import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/insurance_selection_cubit.dart';
import '../bloc/insurance_selection_state.dart';
import '../widgets/neumorphic_container.dart';
import '../widgets/step_indicator.dart';
import 'new_insurance_details_page.dart';

/// Page for selecting insurance category and type
/// Matches UI-2 design with neumorphic selectors and step indicator
class NewInsuranceSelectionPage extends StatelessWidget {
  const NewInsuranceSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InsuranceSelectionCubit(),
      child: const _NewInsuranceSelectionView(),
    );
  }
}

class _NewInsuranceSelectionView extends StatelessWidget {
  const _NewInsuranceSelectionView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: BlocBuilder<InsuranceSelectionCubit, InsuranceSelectionState>(
        builder: (context, state) {
          final selectedCategory =
              state is InsuranceSelectionLoaded ? state.selectedCategory : null;
          final selectedType =
              state is InsuranceSelectionLoaded ? state.selectedType : null;
          final canContinue =
              state is InsuranceSelectionLoaded ? state.canContinue : false;

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
                            .read<InsuranceSelectionCubit>()
                            .selectCategory(category);
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXL),
                  // Step 2: Select Insurance Type
                  _StepSection(
                    stepNumber: 2,
                    title: 'Select Insurance Type',
                    child: _TypeSelector(
                      selectedType: selectedType,
                      onTypeSelected: (type) {
                        context
                            .read<InsuranceSelectionCubit>()
                            .selectType(type);
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXL),
                  // Continue Button
                  _ContinueButton(
                    enabled: canContinue,
                    onPressed: () {
                      // Extract values to help Dart's flow analysis
                      final category = selectedCategory;
                      final type = selectedType;
                      if (category != null && type != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NewInsuranceDetailsPage(
                              category: category,
                              type: type,
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
        'My Insurance',
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

/// Category selector with neumorphic design
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
              label: 'Personal',
              icon: Icons.person_outline,
              isSelected: selectedCategory == 'Personal',
              onTap: () => onCategorySelected('Personal'),
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: _CategoryOption(
              label: 'Asset',
              icon: Icons.business_outlined,
              isSelected: selectedCategory == 'Asset',
              onTap: () => onCategorySelected('Asset'),
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

/// Type selector with neumorphic design
class _TypeSelector extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String> onTypeSelected;

  const _TypeSelector({
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      borderRadius: 40,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingL,
        vertical: AppConstants.spacingL,
      ),
      isSelected: selectedType != null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TypeOption(
            label: 'Health',
            icon: Icons.favorite_border,
            isSelected: selectedType == 'Health',
            onTap: () => onTypeSelected('Health'),
          ),
          _TypeOption(
            label: 'Life',
            icon: Icons.volunteer_activism_outlined,
            isSelected: selectedType == 'Life',
            onTap: () => onTypeSelected('Life'),
          ),
          _TypeOption(
            label: 'Travel',
            icon: Icons.flight_takeoff_outlined,
            isSelected: selectedType == 'Travel',
            onTap: () => onTypeSelected('Travel'),
          ),
          _TypeOption(
            label: 'Accident',
            icon: Icons.warning_amber_outlined,
            isSelected: selectedType == 'Accident',
            onTap: () => onTypeSelected('Accident'),
          ),
        ],
      ),
    );
  }
}

/// Individual type option
class _TypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
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
            const SizedBox(height: AppConstants.spacingXS),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
