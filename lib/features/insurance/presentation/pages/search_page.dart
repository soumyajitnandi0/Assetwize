import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/insurance_detail_cubit.dart';
import '../bloc/search_cubit.dart';
import '../bloc/search_state.dart';
import '../widgets/insurance_card.dart';
import 'insurance_detail_page.dart';

/// Search page for finding insurance policies
///
/// Allows users to search through their saved insurance policies
/// by title, provider, policy number, type, or description.
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

    // Create new timer for debouncing (300ms delay)
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      context.read<SearchCubit>().search(query);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<SearchCubit>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      backgroundColor: Colors.white,
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
        color: Colors.white,
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
          hintText: 'Search by title, provider, policy number...',
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
          fillColor: AppTheme.backgroundLight,
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
            'Search by title, provider, policy number, or type',
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
        final insurance = results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
          child: InsuranceCard(
            insurance: insurance,
            onTap: () => _navigateToDetail(context, insurance.id),
            onAskAssistant: () => _showAssistantSnackBar(context, insurance.title),
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

