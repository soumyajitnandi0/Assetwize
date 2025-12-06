import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Vertical step indicator widget
/// Shows a timeline with circles and connecting line
/// Matches UI-2 design with soft green color
class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildCircle(isActive: currentStep >= 1),
          const SizedBox(height: 16),
          Container(
            width: 2,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.stepIndicatorGreen,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 16),
          _buildCircle(isActive: currentStep >= 2),
        ],
      ),
    );
  }

  Widget _buildCircle({required bool isActive}) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.stepIndicatorGreen : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.stepIndicatorGreen,
          width: 2,
        ),
      ),
    );
  }
}
