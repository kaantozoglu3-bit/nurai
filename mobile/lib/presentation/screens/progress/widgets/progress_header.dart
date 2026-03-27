import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../providers/pain_log_provider.dart';

class StatsRow extends StatelessWidget {
  final int streak;
  final double improvement;
  final bool isPremium;
  final VoidCallback onUnlock;

  const StatsRow({
    super.key,
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
          child: StatCard(
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
          child: StatCard(
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

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;
  final bool locked;
  final VoidCallback onUnlock;

  const StatCard({
    super.key,
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
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppDimensions.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Manrope',
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
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
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

class TodayEntryCard extends StatelessWidget {
  final PainLogScreenState state;
  final PainLogNotifier notifier;

  const TodayEntryCard({
    super.key,
    required this.state,
    required this.notifier,
  });

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
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppDimensions.cardShadow],
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
                  fontFamily: 'Manrope',
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
                    borderRadius: BorderRadius.circular(AppDimensions.radiusChip),
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
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.5),
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
                        fontFamily: 'Manrope',
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

class ProgressErrorBody extends StatelessWidget {
  final VoidCallback onRetry;

  const ProgressErrorBody({super.key, required this.onRetry});

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

