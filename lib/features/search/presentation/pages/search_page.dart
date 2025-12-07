import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../insurance/presentation/pages/chatbot_page.dart';
import '../../../insurance/presentation/pages/insurance_detail_page.dart';
import '../../../insurance/presentation/bloc/insurance_detail_cubit.dart';
import '../../../garage/presentation/pages/garage_detail_view_page.dart';
import '../../../garage/presentation/bloc/garage_detail_cubit.dart';
import '../../../jewellery/presentation/pages/jewellery_detail_view_page.dart';
import '../../../jewellery/presentation/bloc/jewellery_detail_cubit.dart';
import '../../../realty/presentation/pages/realty_detail_view_page.dart';
import '../../../realty/presentation/bloc/realty_detail_cubit.dart';
import '../../domain/entities/search_result.dart';
import '../bloc/search_cubit.dart';
import '../bloc/search_state.dart';
import '../widgets/search_result_card.dart';

/// Unified search page for finding assets across all types
///
/// Allows users to search through their saved assets (Insurance, Garage, Jewellery, Realty)
/// by various fields and displays results from all asset types.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Create new timer for debouncing
    _debounceTimer = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () {
        context.read<SearchCubit>().search(query);
      },
    );
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<SearchCubit>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) => _buildStateContent(context, state),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Search',
        style: GoogleFonts.montserrat(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingL,
        vertical: AppConstants.spacingM,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search all assets...',
          hintStyle: GoogleFonts.montserrat(
            color: AppTheme.textSecondary,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppTheme.textSecondary,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, child) {
              return value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                      color: AppTheme.textSecondary,
                    )
                  : const SizedBox.shrink();
            },
          ),
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[850]
              : AppTheme.backgroundLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusXL),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingM,
            vertical: AppConstants.spacingM,
          ),
        ),
        style: GoogleFonts.montserrat(),
        onChanged: _onSearchChanged,
        autofocus: false,
      ),
    );
  }

  Widget _buildStateContent(BuildContext context, SearchState state) {
    return switch (state) {
      SearchInitial() => _buildInitialView(),
      SearchLoading() => const _LoadingView(),
      SearchLoaded() => _buildResultsView(context, state.results),
      SearchEmpty() => _buildEmptyView(state.query),
      SearchError() => _buildErrorView(state.message),
      _ => _buildInitialView(), // Default fallback
    };
  }

  Widget _buildInitialView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            'Search your assets',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            'Search across Insurances, Vehicles, Jewellery, and Properties',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(BuildContext context, List<dynamic> results) {
    if (results.isEmpty) {
      return _buildEmptyView('');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
          child: SearchResultCard(
            result: result,
            onTap: () => _navigateToDetail(context, result),
            onAskAssistant: () => _navigateToChatbot(context, result),
          ),
        );
      },
    );
  }

  Widget _buildEmptyView(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              'No results found',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              query.isNotEmpty
                  ? 'No assets found for "$query"'
                  : 'Try searching with different keywords',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor.withOpacity(0.7),
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              'Search Error',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              message,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingL),
            ElevatedButton(
              onPressed: () => context.read<SearchCubit>().search(_searchController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, result) {
    switch (result.assetType) {
      case AssetType.insurance:
        final insurance = result.metadata!['insurance'];
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => sl<InsuranceDetailCubit>(),
              child: InsuranceDetailPage(insuranceId: insurance.id),
            ),
          ),
        );
        break;
      case AssetType.garage:
        final garage = result.metadata!['garage'];
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => sl<GarageDetailCubit>(),
              child: GarageDetailViewPage(garageId: garage.id),
            ),
          ),
        );
        break;
      case AssetType.jewellery:
        final jewellery = result.metadata!['jewellery'];
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => sl<JewelleryDetailCubit>(),
              child: JewelleryDetailViewPage(jewelleryId: jewellery.id),
            ),
          ),
        );
        break;
      case AssetType.realty:
        final realty = result.metadata!['realty'];
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => sl<RealtyDetailCubit>(),
              child: RealtyDetailViewPage(realtyId: realty.id),
            ),
          ),
        );
        break;
    }
  }

  void _navigateToChatbot(BuildContext context, result) {
    switch (result.assetType) {
      case AssetType.insurance:
        final insurance = result.metadata!['insurance'];
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatbotPage(insurance: insurance),
          ),
        );
        break;
      case AssetType.garage:
        final garage = result.metadata!['garage'];
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatbotPage(garage: garage),
          ),
        );
        break;
      case AssetType.jewellery:
        final jewellery = result.metadata!['jewellery'];
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatbotPage(jewellery: jewellery),
          ),
        );
        break;
      case AssetType.realty:
        final realty = result.metadata!['realty'];
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatbotPage(realty: realty),
          ),
        );
        break;
    }
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

