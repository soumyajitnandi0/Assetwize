import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../insurance/presentation/pages/chatbot_page.dart';
import '../bloc/jewellery_detail_cubit.dart';
import '../bloc/jewellery_list_cubit.dart';
import '../bloc/jewellery_list_state.dart';
import 'jewellery_detail_view_page.dart';
import 'jewellery_selection_page.dart';
import '../widgets/jewellery_card.dart';
import '../widgets/new_jewellery_card.dart';

/// Main page displaying jewellery items
/// Note: BlocProvider is provided by InsuranceListPage parent
class JewelleryListPage extends StatelessWidget {
  const JewelleryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<JewelleryListCubit, JewelleryListState>(
        builder: (context, state) => _buildStateContent(context, state),
      ),
    );
  }

  Widget _buildStateContent(BuildContext context, JewelleryListState state) {
    return switch (state) {
      JewelleryListLoading() => const _LoadingView(),
      JewelleryListError() => _ErrorView(message: state.message),
      JewelleryListLoaded() => _ContentView(jewelleries: state.jewelleries),
      JewelleryListInitial() => const _LoadingView(),
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
              onPressed: () => context.read<JewelleryListCubit>().retry(),
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
  final List<dynamic> jewelleries;

  const _ContentView({required this.jewelleries});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<JewelleryListCubit>().loadJewelleries(),
      color: AppTheme.primaryGreen,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildNewJewelleryCard(context),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.spacingXL),
          ),
          _buildJewelleryList(context),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.spacingXL),
          ),
        ],
      ),
    );
  }

  Widget _buildNewJewelleryCard(BuildContext context) {
    return SliverToBoxAdapter(
      child: NewJewelleryCard(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const JewellerySelectionPage(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildJewelleryList(BuildContext context) {
    if (jewelleries.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.diamond_outlined,
                size: 64,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(height: AppConstants.spacingM),
              Text(
                'No jewellery yet',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              Text(
                'Add your first jewellery item to get started',
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
        (context, index) => JewelleryCard(
          jewellery: jewelleries[index],
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => sl<JewelleryDetailCubit>(),
                  child: JewelleryDetailViewPage(jewelleryId: jewelleries[index].id),
                ),
              ),
            );
          },
          onAskAssistant: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatbotPage(jewellery: jewelleries[index]),
              ),
            );
          },
        ),
        childCount: jewelleries.length,
      ),
    );
  }
}

