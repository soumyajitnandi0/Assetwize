import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../insurance/presentation/pages/chatbot_page.dart';
import '../bloc/realty_detail_cubit.dart';
import '../bloc/realty_list_cubit.dart';
import '../bloc/realty_list_state.dart';
import 'realty_detail_view_page.dart';
import 'realty_selection_page.dart';
import '../widgets/realty_card.dart';
import '../widgets/new_realty_card.dart';

/// Main page displaying realty properties
/// Note: BlocProvider is provided by InsuranceListPage parent
class RealtyListPage extends StatelessWidget {
  const RealtyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<RealtyListCubit, RealtyListState>(
        builder: (context, state) => _buildStateContent(context, state),
      ),
    );
  }

  Widget _buildStateContent(BuildContext context, RealtyListState state) {
    return switch (state) {
      RealtyListLoading() => const _LoadingView(),
      RealtyListError() => _ErrorView(message: state.message),
      RealtyListLoaded() => _ContentView(realties: state.realties),
      RealtyListInitial() => const _LoadingView(),
      _ => const _LoadingView(),
    };
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
              onPressed: () => context.read<RealtyListCubit>().retry(),
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

/// Main content view with list
class _ContentView extends StatelessWidget {
  final List<dynamic> realties;

  const _ContentView({required this.realties});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<RealtyListCubit>().loadRealties(),
      color: AppTheme.primaryGreen,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildNewRealtyCard(context),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.spacingXL),
          ),
          _buildRealtyList(context),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.spacingXL),
          ),
        ],
      ),
    );
  }

  Widget _buildNewRealtyCard(BuildContext context) {
    return SliverToBoxAdapter(
      child: NewRealtyCard(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const RealtySelectionPage(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRealtyList(BuildContext context) {
    if (realties.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.home_outlined,
                size: 64,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(height: AppConstants.spacingM),
              Text(
                'No properties yet',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              Text(
                'Add your first property to get started',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => RealtyCard(
          realty: realties[index],
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => sl<RealtyDetailCubit>(),
                  child: RealtyDetailViewPage(realtyId: realties[index].id),
                ),
              ),
            );
          },
          onAskAssistant: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatbotPage(realty: realties[index]),
              ),
            );
          },
        ),
        childCount: realties.length,
      ),
    );
  }
}

