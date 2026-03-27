import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pain_log_provider.dart';
import 'widgets/progress_header.dart';
import 'widgets/chart_section.dart';
import 'widgets/pain_body_map.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(currentUserProvider)?.isPremium ?? false;
    final asyncState = ref.watch(painLogProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('İlerleme Takibi'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            ProgressErrorBody(onRetry: () => ref.invalidate(painLogProvider)),
        data: (state) => _ProgressBody(state: state, isPremium: isPremium),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _ProgressBody extends ConsumerWidget {
  final PainLogScreenState state;
  final bool isPremium;

  const _ProgressBody({required this.state, required this.isPremium});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(painLogProvider.notifier);
    final streak = calculateStreak(state.logs);
    final improvement = calculateImprovement(state.logs);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingXXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TodayEntryCard(state: state, notifier: notifier),
          const SizedBox(height: 20),
          StatsRow(
            streak: streak,
            improvement: improvement,
            isPremium: isPremium,
            onUnlock: () => context.go(AppRoutes.paywall),
          ),
          const SizedBox(height: 20),
          WeeklyChartCard(
            logs: state.logs,
            isPremium: isPremium,
            onUnlock: () => context.go(AppRoutes.paywall),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ağrı Haritası',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const PainBodyMap(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
