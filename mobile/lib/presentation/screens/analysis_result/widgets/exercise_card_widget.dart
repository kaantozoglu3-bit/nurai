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
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
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
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _difficultyColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        exercise.difficulty,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
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
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
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
                      fontSize: 12,
                      color: AppColors.textHint,
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
