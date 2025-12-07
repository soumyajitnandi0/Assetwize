import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../garage/presentation/bloc/garage_list_cubit.dart';
import '../../../garage/presentation/pages/garage_list_page.dart';
import '../../../jewellery/presentation/bloc/jewellery_list_cubit.dart';
import '../../../jewellery/presentation/pages/jewellery_list_page.dart';
import '../../../realty/presentation/bloc/realty_list_cubit.dart';
import '../../../realty/presentation/pages/realty_list_page.dart';
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

  // ValueNotifier to communicate tab switches from other pages
  static final ValueNotifier<int?> _tabSwitchNotifier = ValueNotifier<int?>(null);

  /// Static method to switch to garage tab from anywhere
  static void switchToGarageTab() {
    _tabSwitchNotifier.value = 1;
  }

  /// Static method to switch to jewellery tab from anywhere
  static void switchToJewelleryTab() {
    _tabSwitchNotifier.value = 2;
  }

  /// Static method to switch to realty tab from anywhere
  static void switchToRealtyTab() {
    _tabSwitchNotifier.value = 3;
  }
}

class _InsuranceListPageState extends State<InsuranceListPage> {
  int _selectedTabIndex = 0;
  int _garageTabRefreshKey = 0;
  int _jewelleryTabRefreshKey = 0;
  int _realtyTabRefreshKey = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedTabIndex);
    
    // Load insurances when page is first shown
    // This ensures data is loaded even when navigating from welcome page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedTabIndex == 0) {
        context.read<InsuranceListCubit>().loadInsurances();
      }
    });
    
    // Listen for tab switch requests
    InsuranceListPage._tabSwitchNotifier.addListener(_handleTabSwitch);
  }

  @override
  void dispose() {
    _pageController.dispose();
    InsuranceListPage._tabSwitchNotifier.removeListener(_handleTabSwitch);
    super.dispose();
  }

  void _handleTabSwitch() {
    final targetTab = InsuranceListPage._tabSwitchNotifier.value;
    if (targetTab != null && mounted) {
      // If switching to garage, jewellery, or realty tab, increment refresh key to force widget recreation
      if (targetTab == 1) {
        setState(() {
          _selectedTabIndex = targetTab;
          _garageTabRefreshKey++;
        });
      } else if (targetTab == 2) {
        setState(() {
          _selectedTabIndex = targetTab;
          _jewelleryTabRefreshKey++;
        });
      } else if (targetTab == 3) {
        setState(() {
          _selectedTabIndex = targetTab;
          _realtyTabRefreshKey++;
        });
      } else {
        setState(() {
          _selectedTabIndex = targetTab;
        });
      }
      // Animate to the target tab
      _pageController.animateToPage(
        targetTab,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      // Reset the notifier
      InsuranceListPage._tabSwitchNotifier.value = null;
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
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
            onTabSelected: _onTabSelected,
          ),
          const SizedBox(height: AppConstants.spacingM),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildTabContent(0),
                _buildTabContent(1),
                _buildTabContent(2),
                _buildTabContent(3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0: // My Insurances
        return BlocBuilder<InsuranceListCubit, InsuranceListState>(
          builder: (context, state) => _buildStateContent(context, state),
        );
      case 1: // My Garage
        // Use a key to force recreation when refresh key changes
        // This ensures a fresh cubit instance and data refresh
        return BlocProvider(
          key: ValueKey('garage_tab_$_garageTabRefreshKey'),
          create: (_) => sl<GarageListCubit>()..loadGarages(),
          child: const GarageListPage(),
        );
      case 2: // My Jewellery
        return BlocProvider(
          key: ValueKey('jewellery_tab_$_jewelleryTabRefreshKey'),
          create: (_) => sl<JewelleryListCubit>()..loadJewelleries(),
          child: const JewelleryListPage(),
        );
      case 3: // My Realty
        return BlocProvider(
          key: ValueKey('realty_tab_$_realtyTabRefreshKey'),
          create: (_) => sl<RealtyListCubit>()..loadRealties(),
          child: const RealtyListPage(),
        );
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

