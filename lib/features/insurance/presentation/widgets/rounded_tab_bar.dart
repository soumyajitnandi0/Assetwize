import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

// ============================================================================
// ROUNDED TAB BAR WIDGET
// ============================================================================

/// Custom tab bar with icons and green underline indicator
/// Implements horizontal scrolling for multiple tabs
/// Shows 3 tabs at a time, scrolling to reveal more
class RoundedTabBar extends StatefulWidget {
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
  State<RoundedTabBar> createState() => _RoundedTabBarState();
}

class _RoundedTabBarState extends State<RoundedTabBar> {
  late ScrollController _scrollController;
  static const int _tabsVisible = 3;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Scroll to selected tab after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedTab();
    });
  }

  @override
  void didUpdateWidget(RoundedTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Scroll to selected tab when selection changes
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedTab();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedTab() {
    if (!_scrollController.hasClients) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = screenWidth / _tabsVisible;
    final targetOffset = widget.selectedIndex * tabWidth;

    // Calculate the scroll position to center the selected tab
    // or show it within the visible area
    final maxScroll = _scrollController.position.maxScrollExtent;
    final scrollOffset = targetOffset.clamp(0.0, maxScroll);

    _scrollController.animateTo(
      scrollOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = screenWidth / _tabsVisible;

    return SizedBox(
      height: 70,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemCount: widget.tabs.length,
        itemBuilder: (context, index) {
          final tab = widget.tabs[index];
          final isSelected = index == widget.selectedIndex;

          return SizedBox(
            width: tabWidth,
            child: _TabButton(
              tab: tab,
              isSelected: isSelected,
              onTap: () => widget.onTabSelected(index),
            ),
          );
        },
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
          horizontal: AppConstants.spacingM,
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
