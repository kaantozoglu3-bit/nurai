import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PainScoreWidget extends StatelessWidget {
  final int score;

  const PainScoreWidget({super.key, required this.score});

  Color get _color {
    if (score <= 3) return AppColors.success;
    if (score <= 6) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: _color, width: 2),
          ),
          child: Center(
            child: Text(
              '$score',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: _color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ağrı',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
