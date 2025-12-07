import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../insurance/presentation/pages/chatbot_page.dart';
import '../bloc/garage_detail_cubit.dart';
import '../bloc/garage_list_cubit.dart';
import '../bloc/garage_list_state.dart';
import 'garage_detail_view_page.dart';
import 'garage_selection_page.dart';
import '../widgets/garage_card.dart';
import '../widgets/new_garage_card.dart';

/// Main page displaying vehicles in the garage
/// Note: BlocProvider is provided by InsuranceListPage parent
class GarageListPage extends StatelessWidget {
  const GarageListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<GarageListCubit, GarageListState>(
        builder: (context, state) => _buildStateContent(context, state),
      ),
    );
  }

  Widget _buildStateContent(BuildContext context, GarageListState state) {
    return switch (state) {
      GarageListLoading() => const _LoadingView(),
      GarageListError() => _ErrorView(message: state.message),
      GarageListLoaded() => _ContentView(garages: state.garages),
      GarageListInitial() => const _LoadingView(),
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
              onPressed: () => context.read<GarageListCubit>().retry(),
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
  final List<dynamic> garages;

  const _ContentView({required this.garages});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<GarageListCubit>().loadGarages(),
      color: AppTheme.primaryGreen,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildNewGarageCard(context),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.spacingXL),
          ),
          _buildGarageList(context),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.spacingXL),
          ),
        ],
      ),
    );
  }

  Widget _buildNewGarageCard(BuildContext context) {
    return SliverToBoxAdapter(
      child: NewGarageCard(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const GarageSelectionPage(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGarageList(BuildContext context) {
    if (garages.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.directions_car_outlined,
                size: 64,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(height: AppConstants.spacingM),
              Text(
                'No vehicles yet',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              Text(
                'Add your first vehicle to get started',
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
        (context, index) => GarageCard(
          garage: garages[index],
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => sl<GarageDetailCubit>(),
                  child: GarageDetailViewPage(garageId: garages[index].id),
                ),
              ),
            );
          },
          onAskAssistant: () {
            // Navigate to chatbot with garage context
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatbotPage(garage: garages[index]),
              ),
            );
          },
        ),
        childCount: garages.length,
      ),
    );
  }
}

