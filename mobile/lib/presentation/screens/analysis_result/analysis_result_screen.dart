import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/services/analytics_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/analysis_model.dart';
import '../../../data/services/api_service.dart';
import '../../widgets/app_button.dart';
import 'widgets/exercise_card_widget.dart';
import 'widgets/pain_score_widget.dart';
import 'widgets/result_section_title.dart';

class AnalysisResultScreen extends StatefulWidget {
  final Map<String, dynamic> analysisData;

  const AnalysisResultScreen({super.key, required this.analysisData});

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  // exerciseName (lowercase) → video data
  Map<String, Map<String, dynamic>> _exerciseVideoMap = {};
  bool _videosLoading = true;

  late final String _bodyArea =
      widget.analysisData['bodyArea'] as String? ?? 'lower_back';

  late final AnalysisModel _analysis = () {
    final passed = widget.analysisData['analysis'];
    if (passed is AnalysisModel) return passed;
    final bodyAreaLabel =
        widget.analysisData['bodyAreaLabel'] as String? ?? _bodyArea;
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
  }();

  @override
  void initState() {
    super.initState();
    _loadVideos();
    AnalyticsService.instance.logScreenView('analysis_result');
    AnalyticsService.instance.logAnalysisCompleted(
      bodyArea: _bodyArea,
      painScore: _analysis.painScore,
      exerciseCount: _analysis.exercises.length,
    );
  }

  Future<void> _shareAnalysis(BuildContext context) async {
    final analysis = _analysis;
    final exercises = analysis.exercises
        .map((e) => '• ${e.name} — ${e.duration}')
        .join('\n');
    final causes = analysis.possibleCauses.map((c) => '• $c').join('\n');

    final text = '''
Nurai AI Ağrı Analizi — ${analysis.bodyAreaLabel}
Ağrı skoru: ${analysis.painScore}/10

${analysis.aiSummary}

Olası Nedenler:
$causes

Önerilen Egzersizler:
${exercises.isNotEmpty ? exercises : 'Egzersiz önerisi yok'}

⚠️ Bu analiz tıbbi teşhis değildir. Şiddetli ağrılarda doktora başvurun.
'''.trim();

    AnalyticsService.instance.logAnalysisShared(_bodyArea);
    await Share.share(text);
  }

  Future<void> _loadVideos() async {
    if (mounted) setState(() { _videosLoading = true; });
    try {
      final exerciseNames = _analysis.exercises.map((e) => e.name).toList();
      final videos = await ApiService.fetchYoutubeVideos(
        bodyArea: _bodyArea,
        exercises: exerciseNames.isNotEmpty ? exerciseNames : null,
      );
      final map = <String, Map<String, dynamic>>{};
      for (final v in videos) {
        final key = (v['exerciseName'] as String? ?? '').toLowerCase().trim();
        if (key.isNotEmpty && !map.containsKey(key)) map[key] = v;
      }
      if (mounted) setState(() { _exerciseVideoMap = map; _videosLoading = false; });
    } catch (e) {
      if (kDebugMode) debugPrint('[AnalysisResult] Video yükleme başarısız: $e');
      if (mounted) setState(() { _videosLoading = false; });
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
            icon: const Icon(Icons.share_outlined,
                color: AppColors.textPrimary, size: 22),
            tooltip: 'Paylaş',
            onPressed: () => _shareAnalysis(context),
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
                  PainScoreWidget(score: analysis.painScore),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Possible causes
            ResultSectionTitle(title: 'Olası Nedenler', icon: Icons.info_outline),
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
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_outlined,
                      color: AppColors.warning, size: 18),
                  SizedBox(width: 8),
                  Expanded(
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
            ResultSectionTitle(
                title: 'Önerilen Egzersizler', icon: Icons.fitness_center),
            const SizedBox(height: 12),
            if (analysis.exercises.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.textHint, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Egzersiz önerisi oluşturulamadı. Yeni bir analiz yaparak tekrar deneyin.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textHint,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...analysis.exercises.map((exercise) {
                final video =
                    _exerciseVideoMap[exercise.name.toLowerCase().trim()];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ExerciseCardWidget(
                    exercise: exercise,
                    video: video,
                    isVideoLoading: _videosLoading,
                    onVideoTap: video != null
                        ? () {
                            AnalyticsService.instance.logExerciseVideoWatched(
                              exerciseName: exercise.name,
                              videoId: video['videoId'] as String? ?? '',
                            );
                            context.go(
                              AppRoutes.videoPlayer,
                              extra: {
                                'videoId': video['videoId'],
                                'title': video['title'],
                                'channel': video['channelTitle'],
                              },
                            );
                          }
                        : null,
                  ),
                );
              }),
            const SizedBox(height: 24),

            // Share + Premium actions
            AppButton(
              label: 'Analizi Paylaş',
              icon: Icons.share_outlined,
              onPressed: () => _shareAnalysis(context),
              variant: AppButtonVariant.outlined,
            ),
            const SizedBox(height: 12),
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
