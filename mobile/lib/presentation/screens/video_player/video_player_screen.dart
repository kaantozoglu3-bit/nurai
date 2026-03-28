import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/services/athlete_service.dart';
import '../../providers/navigation_provider.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> videoData;

  const VideoPlayerScreen({super.key, required this.videoData});

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isCompleted = false;
  String? _loadError;

  Map<String, dynamic> _effectiveData() {
    if (widget.videoData.isNotEmpty) return widget.videoData;
    return ref.read(videoPlayerDataProvider);
  }

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final data = _effectiveData();

    // 1. Direct URL provided (sports exercises screen passes pre-resolved URL)
    String? videoUrl = data['videoUrl'] as String?;

    // 2. videoId provided (analysis result screen) — AthleteService üzerinden çöz
    if (videoUrl == null || videoUrl.isEmpty) {
      final videoId = data['videoId'] as String? ?? '';
      if (videoId.isEmpty) return;
      videoUrl = AthleteService.getVideoUrlFromId(videoId);
    }

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _videoPlayerController!.initialize().timeout(
        const Duration(seconds: 15),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[VideoPlayer] Hata: $e');
      if (mounted) setState(() => _loadError = 'Video yüklenemedi. Bağlantınızı kontrol edin.');
      return;
    }

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
      aspectRatio: 1080 / 1920,
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.primary,
        handleColor: AppColors.primaryLight,
        backgroundColor: AppColors.surfaceVariant,
        bufferedColor: AppColors.border,
      ),
      errorBuilder: (context, errorMessage) {
        return const Center(
          child: Text(
            'Video yüklenemedi. Sunucu bağlantısını kontrol edin.',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );

    _videoPlayerController!.addListener(() {
      if (_videoPlayerController!.value.position ==
              _videoPlayerController!.value.duration &&
          _videoPlayerController!.value.duration != Duration.zero) {
        if (mounted && !_isCompleted) {
          setState(() => _isCompleted = true);
        }
      }
    });

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _effectiveData();
    final title = data['title'] as String? ?? 'Egzersiz Videosu';
    final description = data['description'] as String? ?? '';

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
            AspectRatio(
              aspectRatio: 1080 / 1920,
              child: _loadError != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _loadError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  : _chewieController != null &&
                          _chewieController!
                              .videoPlayerController.value.isInitialized
                      ? Chewie(controller: _chewieController!)
                      : const Center(
                          child:
                              CircularProgressIndicator(color: AppColors.primary),
                        ),
            ),

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
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
