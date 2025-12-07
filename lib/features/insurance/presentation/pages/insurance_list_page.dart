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
import 'chatbot_page.dart';
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
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load insurances when page is first shown
    // This ensures data is loaded even when navigating from welcome page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedTabIndex == 0) {
        context.read<InsuranceListCubit>().loadInsurances();
      }
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
          _TabSection(
            selectedIndex: _selectedTabIndex,
            onTabSelected: (index) {
              setState(() {
                _selectedTabIndex = index;
              });
            },
          ),
          const SizedBox(height: AppConstants.spacingM),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0: // My Insurances
        return BlocBuilder<InsuranceListCubit, InsuranceListState>(
          builder: (context, state) => _buildStateContent(context, state),
        );
      case 1: // My Garage
        return const _ComingSoonView(title: 'My Garage');
      case 2: // My Jewellery
        return const _ComingSoonView(title: 'My Jewellery');
      case 3: // My Realty
        return const _ComingSoonView(title: 'My Realty');
      default:
        return const _LoadingView();
    }
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
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const _TabSection({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return RoundedTabBar(
      tabs: const [
        TabItem(label: 'My Insurances', icon: Icons.shield_outlined),
        TabItem(label: 'My Garage', icon: Icons.directions_car_outlined),
        TabItem(label: 'My Jewellery', icon: Icons.diamond_outlined),
        TabItem(label: 'My Realty', icon: Icons.home_outlined),
      ],
      selectedIndex: selectedIndex,
      onTabSelected: onTabSelected,
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
      onAskAssistant: () => _showAssistantSnackBar(context, insurance),
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

  void _showAssistantSnackBar(BuildContext context, dynamic insurance) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatbotPage(insurance: insurance),
      ),
    );
  }
}

/// Coming soon view for tabs that are not yet implemented
class _ComingSoonView extends StatelessWidget {
  final String title;

  const _ComingSoonView({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 64,
              color: AppTheme.primaryGreen.withOpacity(0.6),
            ),
            const SizedBox(height: AppConstants.spacingL),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              'Coming Soon',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              'This feature is under development.\nWe\'ll be launching it soon!',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
