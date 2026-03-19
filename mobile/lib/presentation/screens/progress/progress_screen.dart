import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/pain_log_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pain_log_provider.dart';

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
        error: (e, _) => _ErrorBody(onRetry: () => ref.invalidate(painLogProvider)),
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
          // Today entry card — available for everyone
          _TodayEntryCard(state: state, notifier: notifier),
          const SizedBox(height: 20),

          // Stats row — streak + improvement (premium gated)
          _StatsRow(
            streak: streak,
            improvement: improvement,
            isPremium: isPremium,
            onUnlock: () => context.go(AppRoutes.paywall),
          ),
          const SizedBox(height: 20),

          // Weekly chart (premium gated)
          _WeeklyChartCard(
            logs: state.logs,
            isPremium: isPremium,
            onUnlock: () => context.go(AppRoutes.paywall),
          ),
        ],
      ),
    );
  }
}

// ─── Today Entry Card ─────────────────────────────────────────────────────────

class _TodayEntryCard extends StatelessWidget {
  final PainLogScreenState state;
  final PainLogNotifier notifier;

  const _TodayEntryCard({required this.state, required this.notifier});

  Color _scoreColor(int v) {
    if (v <= 3) return AppColors.success;
    if (v <= 6) return AppColors.warning;
    return AppColors.error;
  }

  String _scoreLabel(int v) {
    if (v <= 2) return 'Ağrı yok';
    if (v <= 4) return 'Hafif ağrı';
    if (v <= 6) return 'Orta ağrı';
    if (v <= 8) return 'Şiddetli ağrı';
    return 'Çok şiddetli ağrı';
  }

  @override
  Widget build(BuildContext context) {
    final score = state.sliderValue;
    final color = _scoreColor(score);
    final isSaved = state.savedToday;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXXL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bugünün Ağrı Skoru',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isSaved)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Kaydedildi ✓',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Score display
          Center(
            child: Column(
              children: [
                Text(
                  '$score',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _scoreLabel(score),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.2),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.1),
              trackHeight: 6,
            ),
            child: Slider(
              value: score.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (v) => notifier.updateSlider(v.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '1 — Minimal',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
              Text(
                '10 — Maksimum',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: state.isSaving ? null : notifier.saveToday,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                elevation: 0,
              ),
              child: state.isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isSaved ? 'Güncelle' : 'Kaydet',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int streak;
  final double improvement;
  final bool isPremium;
  final VoidCallback onUnlock;

  const _StatsRow({
    required this.streak,
    required this.improvement,
    required this.isPremium,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department,
            iconColor: const Color(0xFFF97316),
            label: 'Seri',
            value: '$streak gün',
            locked: !isPremium,
            onUnlock: onUnlock,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.trending_up,
            iconColor: AppColors.secondary,
            label: 'İyileşme',
            value: improvement == 0
                ? 'Yetersiz veri'
                : improvement >= 0
                    ? '+${improvement.toStringAsFixed(0)}%'
                    : '${improvement.toStringAsFixed(0)}%',
            valueColor: improvement > 0
                ? AppColors.success
                : improvement < 0
                    ? AppColors.error
                    : AppColors.textSecondary,
            locked: !isPremium,
            onUnlock: onUnlock,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;
  final bool locked;
  final VoidCallback onUnlock;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
    required this.locked,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );

    if (!locked) return card;

    return Stack(
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: card,
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: onUnlock,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: const Center(
                child: Icon(Icons.lock, color: AppColors.primary, size: 22),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Weekly Chart Card ────────────────────────────────────────────────────────

class _WeeklyChartCard extends StatelessWidget {
  final List<PainLogModel> logs;
  final bool isPremium;
  final VoidCallback onUnlock;

  const _WeeklyChartCard({
    required this.logs,
    required this.isPremium,
    required this.onUnlock,
  });

  List<FlSpot> _buildSpots() {
    final now = DateTime.now();
    final spots = <FlSpot>[];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key =
          '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final log = logs.where((l) => l.date == key).firstOrNull;
      if (log != null) {
        spots.add(FlSpot((6 - i).toDouble(), log.score.toDouble()));
      }
    }
    return spots;
  }

  static const List<String> _dayLabels = [
    'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'
  ];

  String _xLabel(double v) {
    final now = DateTime.now();
    final day = now.subtract(Duration(days: 6 - v.toInt()));
    return _dayLabels[day.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final spots = _buildSpots();
    final hasData = spots.isNotEmpty;

    final chartContent = Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXXL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Son 7 Gün',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Günlük ağrı skoru trendi',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          if (!hasData)
            const SizedBox(
              height: 160,
              child: Center(
                child: Text(
                  'Henüz yeterli veri yok.\nGünlük ağrı skorunu kaydetmeye başla.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 6,
                  minY: 1,
                  maxY: 10,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppColors.border,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 3,
                        getTitlesWidget: (v, meta) => Text(
                          v.toInt().toString(),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: 1,
                        getTitlesWidget: (v, meta) => Text(
                          _xLabel(v),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.surface,
                          strokeWidth: 2.5,
                          strokeColor: AppColors.primary,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    if (isPremium) return chartContent;

    return Stack(
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: chartContent,
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: onUnlock,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline,
                      color: AppColors.primary, size: 32),
                  const SizedBox(height: 12),
                  const Text(
                    'Premium özellik',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Haftalık grafik ve istatistikler\nPremium üyeler içindir.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onUnlock,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusS),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                    ),
                    child: const Text(
                      "Premium'a Geç",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Error Body ───────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorBody({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'Veriler yüklenemedi',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
              ),
              child: const Text(
                'Tekrar Dene',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
