import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/insurance_detail_cubit.dart';
import '../bloc/insurance_list_cubit.dart';
import '../bloc/insurance_list_state.dart';
import '../widgets/insurance_card.dart';
import '../widgets/new_insurance_card.dart';
import '../widgets/rounded_tab_bar.dart';
import '../widgets/section_header.dart';
import 'insurance_detail_page.dart';
import 'new_insurance_selection_page.dart';

/// Main page displaying insurance policies with tabs and grid layout
/// Implements clean architecture principles with BLoC pattern
class InsuranceListPage extends StatefulWidget {
  const InsuranceListPage({super.key});

  @override
  State<InsuranceListPage> createState() => _InsuranceListPageState();
}

class _InsuranceListPageState extends State<InsuranceListPage> {
  @override
  void initState() {
    super.initState();
    // Load insurances when page is first shown
    // This ensures data is loaded even when navigating from welcome page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsuranceListCubit>().loadInsurances();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SectionHeader(
            title: 'ASSETWIZE',
          ),
          const _TabSection(),
          const SizedBox(height: AppConstants.spacingM),
          Expanded(
            child: BlocBuilder<InsuranceListCubit, InsuranceListState>(
              builder: (context, state) => _buildStateContent(context, state),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }

  Widget _buildStateContent(BuildContext context, InsuranceListState state) {
    return switch (state) {
      InsuranceListLoading() => const _LoadingView(),
      InsuranceListError() => _ErrorView(message: state.message),
      InsuranceListLoaded() => _ContentView(insurances: state.insurances),
      InsuranceListInitial() =>
        const _LoadingView(), // Show loading for initial state
      _ => const _LoadingView(), // Default to loading
    };
  }
}

/// Tab section widget - extracted for better organization
class _TabSection extends StatelessWidget {
  const _TabSection();

  @override
  Widget build(BuildContext context) {
    return RoundedTabBar(
      tabs: const [
        TabItem(label: 'My Insurances', icon: Icons.shield_outlined),
        TabItem(label: 'My Garage', icon: Icons.directions_car_outlined),
        TabItem(label: 'My Jewellery', icon: Icons.diamond_outlined),
      ],
      selectedIndex: 0,
      onTabSelected: (index) {
        // TODO: Navigate to other asset categories
        debugPrint('Tab selected: $index');
      },
    );
  }
}

/// Loading state view
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.primaryGreen,
      ),
    );
  }
}

/// Error state view with retry functionality
class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingL),
            ElevatedButton.icon(
              onPressed: () => context.read<InsuranceListCubit>().retry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingL,
                  vertical: AppConstants.spacingM,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Main content view with pull-to-refresh and responsive grid
class _ContentView extends StatelessWidget {
  final List<dynamic> insurances;

  const _ContentView({required this.insurances});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<InsuranceListCubit>().loadInsurances(),
      color: AppTheme.primaryGreen,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildNewInsuranceCard(context),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.spacingXL),
          ),
          _buildInsuranceList(context),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.spacingXL),
          ),
        ],
      ),
    );
  }

  Widget _buildNewInsuranceCard(BuildContext context) {
    return SliverToBoxAdapter(
      child: NewInsuranceCard(
        onTap: () => _navigateToNewInsurance(context),
      ),
    );
  }

  Widget _buildInsuranceList(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildInsuranceCard(context, insurances[index]),
        childCount: insurances.length,
      ),
    );
  }

  Widget _buildInsuranceCard(BuildContext context, dynamic insurance) {
    return InsuranceCard(
      insurance: insurance,
      onTap: () => _navigateToDetail(context, insurance.id),
      onAskAssistant: () => _showAssistantSnackBar(context, insurance.title),
    );
  }

  void _navigateToNewInsurance(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NewInsuranceSelectionPage(),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, String insuranceId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<InsuranceDetailCubit>(),
          child: InsuranceDetailPage(insuranceId: insuranceId),
        ),
      ),
    );
  }

  void _showAssistantSnackBar(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ask Assistant about $title'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Bottom navigation bar component
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: const SafeArea(
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                isActive: true,
              ),
              _NavItem(
                icon: Icons.favorite_border,
                activeIcon: Icons.favorite,
                label: 'Favourites',
                isActive: false,
              ),
              _NavItem(
                icon: Icons.search_outlined,
                activeIcon: Icons.search,
                label: 'Search',
                isActive: false,
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Settings',
                isActive: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual navigation item
/// Thin-line style icons with labels below
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            debugPrint('Nav item tapped: $label');
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color:
                    isActive ? AppTheme.primaryGreen : AppTheme.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color:
                      isActive ? AppTheme.primaryGreen : AppTheme.textSecondary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
