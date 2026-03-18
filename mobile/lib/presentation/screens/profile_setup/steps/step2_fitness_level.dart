import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class Step2FitnessLevel extends StatelessWidget {
  final Map<String, dynamic> data;
  final void Function(String key, dynamic value) onChanged;

  const Step2FitnessLevel({
    super.key,
    required this.data,
    required this.onChanged,
  });

  static const _levels = [
    {
      'key': 'sedentary',
      'label': 'Sedanter',
      'desc': 'Çoğunlukla oturarak çalışır, düzenli egzersiz yapmıyorum',
      'icon': Icons.chair_outlined,
    },
    {
      'key': 'light',
      'label': 'Hafif Aktif',
      'desc': 'Haftada 1-2 kez hafif yürüyüş veya egzersiz yapıyorum',
      'icon': Icons.directions_walk_outlined,
    },
    {
      'key': 'moderate',
      'label': 'Orta Aktif',
      'desc': 'Haftada 3-4 kez orta yoğunlukta egzersiz yapıyorum',
      'icon': Icons.directions_run_outlined,
    },
    {
      'key': 'active',
      'label': 'Çok Aktif',
      'desc': 'Haftada 5+ kez düzenli ve yoğun antrenman yapıyorum',
      'icon': Icons.fitness_center_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXXL),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text(
            'Günlük aktivite seviyeni seç. Bu bilgi egzersiz önerilerini kişiselleştirmemize yardımcı olur.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ...(_levels.map((level) {
            final isSelected = data['fitnessLevel'] == level['key'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => onChanged('fitnessLevel', level['key']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.07)
                        : AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          level['icon'] as IconData,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              level['label'] as String,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              level['desc'] as String,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: AppColors.primary, size: 22),
                    ],
                  ),
                ),
              ),
            );
          })),
        ],
      ),
    );
  }
}
