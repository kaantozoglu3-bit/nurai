import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class Step5UserType extends StatelessWidget {
  final Map<String, dynamic> data;
  final void Function(String key, Object? value) onChanged;

  const Step5UserType({
    super.key,
    required this.data,
    required this.onChanged,
  });

  static const _userTypes = [
    {
      'key': 'general',
      'label': 'Genel Kullanıcı',
      'desc': 'Ağrı yönetimi ve kişisel sağlık için',
      'icon': Icons.person_outline,
      'color': Color(0xFF3B82F6),
    },
    {
      'key': 'athlete',
      'label': 'Sporcu',
      'desc': 'Spor performansı ve rehabilitasyon için',
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
            'Hangi kategoride yer almak istiyorsunuz?',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ...(_userTypes.map((userType) {
            final isSelected = data['userType'] == userType['key'];
            final color = userType['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => onChanged('userType', userType['key']),
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
                          userType['icon'] as IconData,
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
                              userType['label'] as String,
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
                              userType['desc'] as String,
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
