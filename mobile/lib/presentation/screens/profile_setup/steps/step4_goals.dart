import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class Step4Goals extends StatelessWidget {
  final Map<String, dynamic> data;
  final void Function(String key, dynamic value) onChanged;

  const Step4Goals({
    super.key,
    required this.data,
    required this.onChanged,
  });

  static const _goals = [
    {
      'key': 'pain_relief',
      'label': 'Ağrıyı Azaltmak',
      'desc': 'Mevcut ağrı ve rahatsızlığı gidermek istiyorum',
      'icon': Icons.healing_outlined,
      'color': Color(0xFFEF4444),
    },
    {
      'key': 'rehabilitation',
      'label': 'Rehabilitasyon',
      'desc': 'Sakatlık veya ameliyat sonrası iyileşme sürecindeyim',
      'icon': Icons.medical_services_outlined,
      'color': Color(0xFF2563EB),
    },
    {
      'key': 'general_health',
      'label': 'Genel Sağlık',
      'desc': 'Vücudumu korumak ve sağlıklı kalmak istiyorum',
      'icon': Icons.favorite_outline,
      'color': Color(0xFF10B981),
    },
    {
      'key': 'sports_performance',
      'label': 'Spor Performansı',
      'desc': 'Atletik performansımı artırmak istiyorum',
      'icon': Icons.sports_outlined,
      'color': Color(0xFFF59E0B),
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
            'Bu uygulamayı kullanmaktaki ana hedefiniz nedir?',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ...(_goals.map((goal) {
            final isSelected = data['goal'] == goal['key'];
            final color = goal['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => onChanged('goal', goal['key']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? color.withValues(alpha: 0.07) : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(
                      color: isSelected ? color : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: isSelected ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          goal['icon'] as IconData,
                          color: color,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal['label'] as String,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? color
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              goal['desc'] as String,
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
                        Icon(Icons.check_circle, color: color, size: 22),
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
