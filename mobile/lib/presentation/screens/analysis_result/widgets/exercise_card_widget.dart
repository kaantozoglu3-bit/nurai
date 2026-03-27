import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../data/models/analysis_model.dart';
import 'video_loading_shimmer.dart';
import 'video_row_widget.dart';

class ExerciseCardWidget extends StatelessWidget {
  final ExerciseModel exercise;
  final Map<String, dynamic>? video;
  final bool isVideoLoading;
  final VoidCallback? onVideoTap;

  const ExerciseCardWidget({
    super.key,
    required this.exercise,
    this.video,
    this.isVideoLoading = false,
    this.onVideoTap,
  });

  Color get _difficultyColor {
    switch (exercise.difficulty) {
      case 'Kolay':
        return AppColors.success;
      case 'Orta':
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusItem),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [AppDimensions.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppDimensions.radiusIcon),
                        ),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _difficultyColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        exercise.difficulty,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _difficultyColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.repeat,
                        color: AppColors.textHint, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      exercise.duration,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (exercise.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    exercise.description,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isVideoLoading)
            const VideoLoadingShimmer()
          else if (video != null)
            VideoRowWidget(video: video!, onTap: onVideoTap),
        ],
      ),
    );
  }
}
