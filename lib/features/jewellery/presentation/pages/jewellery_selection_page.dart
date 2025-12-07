import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/jewellery_selection_cubit.dart';
import '../bloc/jewellery_selection_state.dart';
import '../../../insurance/presentation/widgets/neumorphic_container.dart';
import '../../../insurance/presentation/widgets/step_indicator.dart';
import 'jewellery_details_page.dart';

/// Page for selecting jewellery category and item name
class JewellerySelectionPage extends StatelessWidget {
  const JewellerySelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JewellerySelectionCubit(),
      child: const _JewellerySelectionView(),
    );
  }
}

class _JewellerySelectionView extends StatelessWidget {
  const _JewellerySelectionView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: BlocBuilder<JewellerySelectionCubit, JewellerySelectionState>(
        builder: (context, state) {
          final selectedCategory =
              state is JewellerySelectionLoaded ? state.selectedCategory : null;
          final itemName =
              state is JewellerySelectionLoaded ? state.itemName : null;
          final isAcknowledged =
              state is JewellerySelectionLoaded ? state.isAcknowledged : false;
          final canContinue =
              state is JewellerySelectionLoaded ? state.canContinue : false;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingL,
                vertical: AppConstants.spacingM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step 1: Select Category
                  _StepSection(
                    stepNumber: 1,
                    title: 'Select Jewellery Category',
                    child: _CategorySelector(
                      selectedCategory: selectedCategory,
                      onCategorySelected: (category) {
                        context
                            .read<JewellerySelectionCubit>()
                            .selectCategory(category);
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXL),
                  // Step 2: Item Name
                  _StepSection(
                    stepNumber: 2,
                    title: 'Item Name',
                    child: _ItemNameInput(
                      itemName: itemName,
                      onItemNameChanged: (value) {
                        context
                            .read<JewellerySelectionCubit>()
                            .setItemName(value);
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXL),
                  // Disclaimer
                  _DisclaimerCheckbox(
                    isAcknowledged: isAcknowledged,
                    onChanged: (value) {
                      context
                          .read<JewellerySelectionCubit>()
                          .setAcknowledged(value);
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingXL),
                  // Continue Button
                  _ContinueButton(
                    canContinue: canContinue,
                    onPressed: canContinue
                        ? () {
                            final category = selectedCategory;
                            final name = itemName;
                            if (category != null && name != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => JewelleryDetailsPage(
                                    category: category,
                                    itemName: name,
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
        'My Jewellery',
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
              label: 'Gold',
              icon: Icons.diamond,
              isSelected: selectedCategory == 'Gold',
              onTap: () => onCategorySelected('Gold'),
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: _CategoryOption(
              label: 'Silver',
              icon: Icons.circle,
              isSelected: selectedCategory == 'Silver',
              onTap: () => onCategorySelected('Silver'),
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: _CategoryOption(
              label: 'Diamond',
              icon: Icons.diamond_outlined,
              isSelected: selectedCategory == 'Diamond',
              onTap: () => onCategorySelected('Diamond'),
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: _CategoryOption(
              label: 'Platinum',
              icon: Icons.star,
              isSelected: selectedCategory == 'Platinum',
              onTap: () => onCategorySelected('Platinum'),
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

/// Item name input field
class _ItemNameInput extends StatelessWidget {
  final String? itemName;
  final ValueChanged<String> onItemNameChanged;

  const _ItemNameInput({
    required this.itemName,
    required this.onItemNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      isSelected: itemName != null && itemName!.isNotEmpty,
      child: TextField(
        onChanged: onItemNameChanged,
        decoration: InputDecoration(
          hintText: 'e.g., Necklace, Ring, Earrings',
          border: InputBorder.none,
          hintStyle: GoogleFonts.montserrat(
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
        ),
        style: GoogleFonts.montserrat(
          color: AppTheme.textPrimary,
        ),
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

