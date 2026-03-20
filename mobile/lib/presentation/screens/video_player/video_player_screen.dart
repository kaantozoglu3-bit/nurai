import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../providers/navigation_provider.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> videoData;

  const VideoPlayerScreen({super.key, required this.videoData});

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  YoutubePlayerController? _controller;
  bool _isCompleted = false;

  /// Returns the effective video data map: widget field first (backwards-
  /// compatible callers), then the Riverpod provider (set by the caller
  /// before navigating to avoid state.extra deep-link breakage).
  Map<String, dynamic> _effectiveData() {
    if (widget.videoData.isNotEmpty) return widget.videoData;
    return ref.read(videoPlayerDataProvider);
  }

  @override
  void initState() {
    super.initState();
    final videoId = _effectiveData()['videoId'] as String? ?? '';
    if (videoId.isNotEmpty) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _effectiveData();
    final title = data['title'] as String? ?? 'Egzersiz Videosu';
    final channel = data['channel'] as String? ?? '';

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller ??
            YoutubePlayerController(
              initialVideoId: 'dQw4w9WgXcQ',
              flags: const YoutubePlayerFlags(autoPlay: false),
            ),
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.primary,
        onEnded: (_) => setState(() => _isCompleted = true),
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary, size: 20),
              onPressed: () => context.pop(),
            ),
            title: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video player
                player,

                // Info
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingXXL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (channel.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          channel,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Completed button
                      if (!_isCompleted)
                        OutlinedButton.icon(
                          onPressed: () => setState(() => _isCompleted = true),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Egzersizi Tamamladım'),
                          style: OutlinedButton.styleFrom(
                            minimumSize:
                                const Size(double.infinity, AppDimensions.buttonHeight),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusS),
                            border: Border.all(
                                color: AppColors.success.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle,
                                  color: AppColors.success, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'Egzersiz tamamlandı! Harika iş!',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),

                      // Favorites
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon:
                                  const Icon(Icons.favorite_border, size: 18),
                              label: const Text('Favorilere Ekle'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 44),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.share_outlined, size: 18),
                              label: const Text('Paylaş'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 44),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
