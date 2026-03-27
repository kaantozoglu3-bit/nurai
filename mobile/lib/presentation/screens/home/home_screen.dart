import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/weekly_progress_provider.dart';
import '../library/library_screen.dart';
import '../progress/progress_screen.dart';
import '../program/program_screen.dart';
import '../../providers/quick_exercise_provider.dart';
import 'widgets/quota_card.dart';
import 'widgets/empty_analysis_state.dart';
import 'widgets/profile_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final displayName = user?.displayName ?? 'Kullanıcı';
    final firstName = displayName.split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _HomeTab(firstName: firstName, user: user),
          const ProgramScreen(),
          const ProgressScreen(),
          const LibraryScreen(),
          const ProfileTab(),
        ],
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: const [AppDimensions.navShadow],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i),
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.onSurfaceVariant,
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurfaceVariant,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Anasayfa',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  activeIcon: Icon(Icons.calendar_today),
                  label: 'Program',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_outlined),
                  activeIcon: Icon(Icons.bar_chart),
                  label: 'İlerleme',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book_outlined),
                  activeIcon: Icon(Icons.menu_book),
                  label: 'Kütüphane',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  final String firstName;
  final UserModel? user;

  const _HomeTab({required this.firstName, this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remaining = user?.remainingAnalyses ?? 3;
    final isPremium = user?.isPremium ?? false;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingXXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Merhaba, $firstName!',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Bugün nasıl hissediyorsun?',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Main CTA
            _AnalysisCta(),
            const SizedBox(height: 20),

            // Weekly progress
            _WeeklyProgressCard(),
            const SizedBox(height: 16),

            // Hızlı Egzersiz card
            _QuickExerciseCard(),
            const SizedBox(height: 16),

            // Quota card
            if (!isPremium) QuotaCard(remaining: remaining),
            const SizedBox(height: 24),

            // Son Analizler
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Son Analizler',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go(AppRoutes.history),
                  child: const Text(
                    'Tümünü Gör',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            const EmptyAnalysisState(),
          ],
        ),
      ),
    );
  }
}

// ─── Analysis CTA ─────────────────────────────────────────────────────────────

class _AnalysisCta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingXXL),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        boxShadow: const [AppDimensions.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.self_improvement, color: Colors.white70, size: 36),
          const SizedBox(height: 16),
          const Text(
            'Ağrını Analiz Et',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'AI destekli analiz ile ağrının nedenini bul ve kişiselleştirilmiş egzersizlere başla.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Semantics(
            label: 'Ağrı analizi başlat',
            button: true,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => context.go(AppRoutes.bodySelector),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Başla',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Weekly Progress Card ─────────────────────────────────────────────────────

class _WeeklyProgressCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(weeklyProgressProvider);

    return progress.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (data) {
        final done = data['done'] ?? 0;
        final goal = data['goal'] ?? 3;
        final ratio = goal > 0 ? (done / goal).clamp(0.0, 1.0) : 0.0;
        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusItem),
            boxShadow: const [AppDimensions.cardShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bu Haftaki İlerleme',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    '$done / $goal egzersiz',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 8,
                  backgroundColor:
                      AppColors.primary.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Quick Exercise Card ──────────────────────────────────────────────────────

class _QuickExerciseCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quickExerciseProvider);
    final areaLabel = getTodayAreaLabel();
    final isDone = state.isDoneToday;

    return Semantics(
      label: isDone ? 'Bugünkü egzersiz tamamlandı' : 'Günlük hızlı egzersizi başlat',
      button: !isDone,
      child: GestureDetector(
      onTap: isDone ? null : () => context.push(AppRoutes.quickExercise),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusItem),
          boxShadow: const [AppDimensions.cardShadow],
          border: isDone
              ? Border.all(color: AppColors.success.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusIcon),
              ),
              child: Icon(
                isDone ? Icons.check_circle : Icons.fitness_center,
                color: isDone ? AppColors.success : AppColors.secondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDone
                        ? 'Bugünkü Egzersiz Tamamlandı!'
                        : 'Bugünün Hızlı Egzersizi',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDone ? AppColors.success : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDone
                        ? 'Yarın $areaLabel egzersizleri seni bekliyor'
                        : '$areaLabel · 3 egzersiz · ~5 dakika',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (!isDone)
              const Icon(Icons.chevron_right,
                  color: AppColors.secondary, size: 20),
          ],
        ),
      ),
    ),
    );
  }
}

