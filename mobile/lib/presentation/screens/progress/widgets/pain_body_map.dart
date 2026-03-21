import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/services/history_service.dart';

final painBodyMapProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final analyses = await HistoryService.fetchHistory();
  final counts = <String, int>{};
  for (final a in analyses) {
    if (a.bodyArea.isNotEmpty) {
      counts[a.bodyArea] = (counts[a.bodyArea] ?? 0) + 1;
    }
  }
  return counts;
});

class PainBodyMap extends ConsumerWidget {
  const PainBodyMap({super.key});

  static const Map<String, String> _labels = {
    'neck': 'Boyun',
    'upper_back': 'Üst Sırt',
    'lower_back': 'Bel',
    'left_shoulder': 'Sol Omuz',
    'right_shoulder': 'Sağ Omuz',
    'left_knee': 'Sol Diz',
    'right_knee': 'Sağ Diz',
    'hip': 'Kalça',
    'core': 'Karın',
    'left_elbow': 'Sol Dirsek',
    'right_elbow': 'Sağ Dirsek',
    'left_wrist': 'Sol Bilek',
    'right_wrist': 'Sağ Bilek',
    'left_ankle': 'Sol Ayak Bileği',
    'right_ankle': 'Sağ Ayak Bileği',
  };

  Color _colorForCount(int count, int maxCount) {
    if (maxCount == 0) return AppColors.border;
    final ratio = count / maxCount;
    if (ratio >= 0.7) return const Color(0xFFEF4444);
    if (ratio >= 0.4) return const Color(0xFFF97316);
    if (ratio >= 0.2) return const Color(0xFFFBBF24);
    return const Color(0xFF86EFAC);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(painBodyMapProvider);

    return async.when(
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => const SizedBox.shrink(),
      data: (counts) {
        if (counts.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text(
                'Henüz analiz kaydı yok.\nAnaliz yaptıkça ağrı haritanız oluşacak.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          );
        }

        final maxCount =
            counts.values.reduce((a, b) => a > b ? a : b);
        final sorted = counts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Renk skalası göstergesi
            Row(
              children: [
                _LegendDot(
                    color: const Color(0xFF86EFAC), label: 'Az'),
                const SizedBox(width: 12),
                _LegendDot(
                    color: const Color(0xFFFBBF24), label: 'Orta'),
                const SizedBox(width: 12),
                _LegendDot(
                    color: const Color(0xFFF97316), label: 'Yüksek'),
                const SizedBox(width: 12),
                _LegendDot(
                    color: const Color(0xFFEF4444), label: 'Kritik'),
              ],
            ),
            const SizedBox(height: 12),
            // Bölge listesi
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sorted.map((entry) {
                final label = _labels[entry.key] ?? entry.key;
                final color = _colorForCount(entry.value, maxCount);
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$label (${entry.value}x)',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color.withAlpha(220),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
