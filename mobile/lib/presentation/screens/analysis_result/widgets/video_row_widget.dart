import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class VideoRowWidget extends StatelessWidget {
  final Map<String, dynamic> video;
  final VoidCallback? onTap;

  const VideoRowWidget({super.key, required this.video, this.onTap});

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = video['thumbnailUrl'] as String? ?? '';
    final title = video['title'] as String? ?? '';
    final duration = video['duration'] as String? ?? '--:--';

    return Container(
      margin: const EdgeInsets.fromLTRB(AppDimensions.paddingL, 0,
          AppDimensions.paddingL, AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusItem),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [AppDimensions.cardShadow],
      ),
      child: Row(
        children: [
          // Thumbnail with duration badge
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppDimensions.radiusItem)),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: thumbnailUrl,
                  width: 88,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: AppColors.border,
                    highlightColor: AppColors.surface,
                    child: Container(
                        width: 88, height: 60, color: AppColors.border),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 88,
                    height: 60,
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.play_circle_outline,
                        color: AppColors.textHint, size: 24),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      duration,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.onSurface,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow, color: Colors.white, size: 14),
                  SizedBox(width: 3),
                  Text(
                    'İzle',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
