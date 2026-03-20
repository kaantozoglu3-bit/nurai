import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../widgets/app_text_field.dart';

class Step3InjuryHistory extends StatelessWidget {
  final Map<String, dynamic> data;
  final void Function(String key, Object? value) onChanged;

  const Step3InjuryHistory({
    super.key,
    required this.data,
    required this.onChanged,
  });

  static const _injuries = [
    'Diz ameliyatı / sakatlığı',
    'Bel fıtığı',
    'Boyun fıtığı',
    'Omuz çıkığı / ameliyatı',
    'Kırık / çatlak geçmişi',
    'Kronik eklem ağrısı',
    'Hiçbiri',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedInjuries = List<String>.from(data['injuries'] as List);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXXL),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text(
            'Daha güvenli egzersiz önerileri sunabilmek için geçmiş sakatlıklarını belirt.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ...(_injuries.map((injury) {
            final isSelected = selectedInjuries.contains(injury);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  final updated = List<String>.from(selectedInjuries);
                  if (injury == 'Hiçbiri') {
                    updated.clear();
                    updated.add('Hiçbiri');
                  } else {
                    updated.remove('Hiçbiri');
                    if (isSelected) {
                      updated.remove(injury);
                    } else {
                      updated.add(injury);
                    }
                  }
                  onChanged('injuries', updated);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.07)
                        : AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusS),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textHint,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          injury,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          })),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Diğer (açıklayınız)',
            hint: 'Belirtmek istediğiniz başka bir durum var mı?',
            maxLines: 3,
            onChanged: (v) => onChanged('otherInjury', v),
          ),
        ],
      ),
    );
  }
}
