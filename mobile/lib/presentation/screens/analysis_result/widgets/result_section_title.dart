import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ResultSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const ResultSectionTitle({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
