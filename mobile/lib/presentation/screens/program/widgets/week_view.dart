import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../data/models/weekly_program_model.dart';
import 'day_card.dart';

class WeekView extends StatelessWidget {
  final ProgramWeek week;
  final WeeklyProgramModel program;
  final void Function(int dayNumber) onToggle;

  const WeekView({
    super.key,
    required this.week,
    required this.program,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      children: [
        // Week header
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                week.title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                week.focus,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        ...week.days.map(
          (day) => DayCard(
            day: day,
            weekNumber: week.weekNumber,
            isCompleted: program.isDayCompleted(week.weekNumber, day.dayNumber),
            onToggle: () => onToggle(day.dayNumber),
          ),
        ),
      ],
    );
  }
}
