import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../data/models/pain_log_model.dart';

class WeeklyChartCard extends StatelessWidget {
  final List<PainLogModel> logs;
  final bool isPremium;
  final VoidCallback onUnlock;

  const WeeklyChartCard({
    super.key,
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
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppDimensions.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Son 7 Gün',
            style: TextStyle(
              fontFamily: 'Manrope',
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
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
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
                      fontFamily: 'Manrope',
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
