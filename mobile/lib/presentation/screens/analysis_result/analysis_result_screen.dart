import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/analysis_model.dart';
import '../../../data/services/api_service.dart';
import '../../widgets/app_button.dart';

class AnalysisResultScreen extends StatefulWidget {
  final Map<String, dynamic> analysisData;

  const AnalysisResultScreen({super.key, required this.analysisData});

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  List<Map<String, dynamic>> _youtubeVideos = [];
  bool _videosLoading = true;
  String? _videoError;

  String get _bodyArea =>
      widget.analysisData['bodyArea'] as String? ?? 'lower_back';

  AnalysisModel get _analysis {
    final passed = widget.analysisData['analysis'];
    if (passed is AnalysisModel) return passed;
    // Fallback: build minimal model from available data
    final bodyAreaLabel = MockData.bodyAreaLabels[_bodyArea] ?? _bodyArea;
    return AnalysisModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bodyArea: _bodyArea,
      bodyAreaLabel: bodyAreaLabel,
      painScore: widget.analysisData['painScore'] as int? ?? 5,
      userComplaint: '',
      aiSummary: widget.analysisData['aiSummary'] as String? ??
          '$bodyAreaLabel bölgesinde ağrı analizi tamamlandı.',
      possibleCauses: (widget.analysisData['possibleCauses'] as List?)
              ?.cast<String>() ??
          ['Kas gerilmesi', 'Postür bozukluğu'],
      exercises: [],
      videos: [],
      createdAt: DateTime.now(),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  List<String> get _exercises {
    final raw = widget.analysisData['exercises'];
    if (raw is List) return raw.cast<String>();
    return [];
  }

  Future<void> _loadVideos() async {
    try {
      final videos = await ApiService.fetchYoutubeVideos(
        bodyArea: _bodyArea,
        exercises: _exercises.isNotEmpty ? _exercises : null,
      );
      if (mounted) setState(() { _youtubeVideos = videos; _videosLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _videoError = e.toString(); _videosLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final analysis = _analysis;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: const Text('Analiz Sonucu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingXXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pain score header
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingXXL),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2), width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          analysis.bodyAreaLabel,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          analysis.aiSummary,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _PainScore(score: analysis.painScore),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Possible causes
            _SectionTitle(title: 'Olası Nedenler', icon: Icons.info_outline),
            const SizedBox(height: 12),
            ...analysis.possibleCauses.map((cause) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          cause,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_outlined,
                      color: AppColors.warning, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Bu analiz tıbbi teşhis değildir. Şiddetli veya uzun süren ağrılarda lütfen bir doktora başvurun.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.warning,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Exercises
            _SectionTitle(
                title: 'Önerilen Egzersizler', icon: Icons.fitness_center),
            const SizedBox(height: 12),
            ...analysis.exercises.map((exercise) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ExerciseCard(
                    exercise: exercise,
                    onTap: exercise.videoId != null
                        ? () => context.go(
                              AppRoutes.videoPlayer,
                              extra: {
                                'videoId': exercise.videoId,
                                'title': exercise.name,
                              },
                            )
                        : null,
                  ),
                )),
            const SizedBox(height: 24),

            // Videos
            _SectionTitle(
                title: 'Egzersiz Videoları',
                icon: Icons.play_circle_outline),
            const SizedBox(height: 12),
            if (_videosLoading)
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, sep) =>
                      const SizedBox(width: AppDimensions.paddingM),
                  itemBuilder: (context, i) => Shimmer.fromColors(
                    baseColor: AppColors.border,
                    highlightColor: AppColors.surface,
                    child: Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusM),
                      ),
                    ),
                  ),
                ),
              )
            else if (_videoError != null || _youtubeVideos.isEmpty)
              Container(
                height: 80,
                alignment: Alignment.center,
                child: Text(
                  'Videolar yüklenemedi.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                ),
              )
            else
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _youtubeVideos.length,
                  separatorBuilder: (_, sep) =>
                      const SizedBox(width: AppDimensions.paddingM),
                  itemBuilder: (context, i) {
                    final v = _youtubeVideos[i];
                    return _YoutubeVideoCard(
                      videoId: v['videoId'] as String,
                      title: v['title'] as String,
                      channelTitle: v['channelTitle'] as String,
                      thumbnailUrl: v['thumbnailUrl'] as String,
                      duration: v['duration'] as String,
                      onTap: () => context.go(
                        AppRoutes.videoPlayer,
                        extra: {
                          'videoId': v['videoId'],
                          'title': v['title'],
                          'channel': v['channelTitle'],
                        },
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),

            // Premium actions
            AppButton(
              label: 'Egzersiz Programı Oluştur',
              icon: Icons.calendar_today_outlined,
              onPressed: () => context.go(AppRoutes.paywall),
              variant: AppButtonVariant.outlined,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Fizyoterapiste Danış',
              icon: Icons.people_outline,
              onPressed: () => context.go(AppRoutes.paywall),
              variant: AppButtonVariant.ghost,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PainScore extends StatelessWidget {
  final int score;

  const _PainScore({required this.score});

  Color get _color {
    if (score <= 3) return AppColors.success;
    if (score <= 6) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: _color, width: 2),
          ),
          child: Center(
            child: Text(
              '$score',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: _color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ağrı',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final VoidCallback? onTap;

  const _ExerciseCard({required this.exercise, this.onTap});

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
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: AppColors.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _difficultyColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
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
                    const SizedBox(width: 8),
                    Text(
                      exercise.duration,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onTap != null)
            IconButton(
              icon: const Icon(Icons.play_circle_filled,
                  color: AppColors.primary, size: 32),
              onPressed: onTap,
            ),
        ],
      ),
    );
  }
}

class _YoutubeVideoCard extends StatelessWidget {
  final String videoId;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;
  final String duration;
  final VoidCallback onTap;

  const _YoutubeVideoCard({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
    required this.duration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusM)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: thumbnailUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: AppColors.border,
                      highlightColor: AppColors.surface,
                      child: Container(height: 100, color: AppColors.border),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 100,
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.play_circle_outline,
                          color: AppColors.textHint, size: 36),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
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
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    channelTitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: AppColors.textSecondary,
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

