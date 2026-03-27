import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class VideoLoadingShimmer extends StatelessWidget {
  const VideoLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.paddingL, 0,
          AppDimensions.paddingL, AppDimensions.paddingL),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusItem),
        child: Shimmer.fromColors(
          baseColor: AppColors.outlineVariant,
          highlightColor: AppColors.surfaceContainerLow,
          child: Container(
            height: 56,
            color: AppColors.outlineVariant,
          ),
        ),
      ),
    );
  }
}
