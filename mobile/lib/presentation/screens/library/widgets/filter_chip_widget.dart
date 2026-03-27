import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.secondaryContainer,
          borderRadius: BorderRadius.circular(AppDimensions.radiusChip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (locked) ...[
              const Icon(Icons.lock, size: 12, color: AppColors.textHint),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: locked
                    ? AppColors.textHint
                    : selected
                        ? Colors.white
                        : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
