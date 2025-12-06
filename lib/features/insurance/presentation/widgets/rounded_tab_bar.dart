import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

// ============================================================================
// ROUNDED TAB BAR WIDGET
// ============================================================================

/// Custom tab bar with icons and green underline indicator
/// Implements horizontal scrolling for multiple tabs
class RoundedTabBar extends StatelessWidget {
  final List<TabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const RoundedTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingL,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(tabs.length, (index) {
            final tab = tabs[index];
            final isSelected = index == selectedIndex;

            return Expanded(
              child: _TabButton(
                tab: tab,
                isSelected: isSelected,
                onTap: () => onTabSelected(index),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Individual tab button widget
class _TabButton extends StatelessWidget {
  final TabItem tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacingS,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
              width: 2.0, // 2px thickness as per spec
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tab.icon,
              size: 24,
              color:
                  isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              tab.label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color:
                    isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab item model
class TabItem {
  final String label;
  final IconData icon;

  const TabItem({
    required this.label,
    required this.icon,
  });
}
