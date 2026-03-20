import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../widgets/app_text_field.dart';

class Step1BasicInfo extends StatelessWidget {
  final Map<String, dynamic> data;
  final void Function(String key, Object? value) onChanged;

  const Step1BasicInfo({
    super.key,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXXL),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text(
            'Sağlık profilini oluşturmak için temel bilgilerini girerek başlayalım.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          AppTextField(
            label: 'Yaşınız',
            hint: '30',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.cake_outlined,
            onChanged: (v) => onChanged('age', int.tryParse(v)),
          ),
          const SizedBox(height: AppDimensions.paddingL),

          // Gender
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cinsiyet',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Row(
                children: [
                  _GenderChip(
                    label: 'Erkek',
                    icon: Icons.man,
                    isSelected: data['gender'] == 'male',
                    onTap: () => onChanged('gender', 'male'),
                  ),
                  const SizedBox(width: 8),
                  _GenderChip(
                    label: 'Kadın',
                    icon: Icons.woman,
                    isSelected: data['gender'] == 'female',
                    onTap: () => onChanged('gender', 'female'),
                  ),
                  const SizedBox(width: 8),
                  _GenderChip(
                    label: 'Belirtmek İstemiyorum',
                    icon: Icons.person,
                    isSelected: data['gender'] == 'other',
                    onTap: () => onChanged('gender', 'other'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingL),

          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Boy (cm)',
                  hint: '175',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.height,
                  onChanged: (v) => onChanged('height', int.tryParse(v)),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: AppTextField(
                  label: 'Kilo (kg)',
                  hint: '70',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.monitor_weight_outlined,
                  onChanged: (v) => onChanged('weight', int.tryParse(v)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
