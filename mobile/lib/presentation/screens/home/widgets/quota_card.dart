import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../data/services/quota_service.dart';

class QuotaCard extends StatelessWidget {
  final int remaining;

  const QuotaCard({super.key, required this.remaining});

  static const int _dailyLimit = QuotaService.dailyLimit;

  @override
  Widget build(BuildContext context) {
    final ratio = (_dailyLimit > 0) ? remaining / _dailyLimit : 0.0;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusItem),
        boxShadow: const [AppDimensions.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: remaining > 0
                  ? AppColors.secondary.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusIcon),
            ),
            child: Icon(
              Icons.analytics_outlined,
              color:
                  remaining > 0 ? AppColors.secondary : AppColors.error,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  remaining > 0
                      ? 'Bugün $remaining analiz hakkın kaldı'
                      : 'Günlük $_dailyLimit analiz hakkın doldu',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio.clamp(0.0, 1.0),
                    backgroundColor: AppColors.surfaceContainerLow,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      remaining > 0
                          ? AppColors.secondary
                          : AppColors.error,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          if (remaining == 0) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: () => context.go(AppRoutes.paywall),
              child: const Text(
                'Premium',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
