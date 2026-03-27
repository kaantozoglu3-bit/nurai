import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/services/analytics_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/analysis_model.dart';
import '../../providers/ad_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/app_button.dart';
import 'widgets/exercise_card_widget.dart';
import 'widgets/pain_score_widget.dart';
import 'widgets/result_section_title.dart';

class AnalysisResultScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> analysisData;

  const AnalysisResultScreen({super.key, required this.analysisData});

  @override
  ConsumerState<AnalysisResultScreen> createState() =>
      _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends ConsumerState<AnalysisResultScreen> {
  bool _videosLoading = true;

  /// Returns the effective analysis data: widget field first (passed via
  /// constructor for backwards-compatible callers), then provider state
  /// (set before navigating from ChatScreen).
  Map<String, dynamic> _effectiveData() {
    if (widget.analysisData.isNotEmpty) return widget.analysisData;
    return ref.read(analysisResultDataProvider);
  }

  late final String _bodyArea = _effectiveData()['bodyArea'] as String? ?? 'lower_back';

  late final AnalysisModel _analysis = () {
    final data = _effectiveData();
    final passed = data['analysis'];
    if (passed is AnalysisModel) return passed;
    final bodyAreaLabel =
        data['bodyAreaLabel'] as String? ?? _bodyArea;
    return AnalysisModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bodyArea: _bodyArea,
      bodyAreaLabel: bodyAreaLabel,
      painScore: data['painScore'] as int? ?? 5,
      userComplaint: '',
      aiSummary: data['aiSummary'] as String? ??
          '$bodyAreaLabel bölgesinde ağrı analizi tamamlandı.',
      possibleCauses: (data['possibleCauses'] as List?)
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
    // Local videos are immediately available from the AI model
    if (mounted) setState(() => _videosLoading = false);
  }

  Color _headerBackgroundColor(int score) {
    if (score >= 7) {
      return AppColors.error.withValues(alpha: 0.06);
    } else if (score >= 4) {
      return AppColors.warning.withValues(alpha: 0.06);
    } else {
      return AppColors.success.withValues(alpha: 0.06);
    }
  }

  Color _headerBorderColor(int score) {
    if (score >= 7) {
      return AppColors.error.withValues(alpha: 0.2);
    } else if (score >= 4) {
      return AppColors.warning.withValues(alpha: 0.2);
    } else {
      return AppColors.success.withValues(alpha: 0.2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final analysis = _analysis;
    final isPremium = ref.watch(currentUserProvider)?.isPremium ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: const Text(
          'Analiz Sonucu',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
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
                color: _headerBackgroundColor(analysis.painScore),
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(
                    color: _headerBorderColor(analysis.painScore), width: 1),
                boxShadow: const [AppDimensions.cardShadow],
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
                            fontFamily: 'Manrope',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
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
            Divider(
              color: AppColors.border.withValues(alpha: 0.5),
              height: 1,
              thickness: 1,
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
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusItem),
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
                final video = exercise.videoId != null && exercise.videoId!.isNotEmpty
                    ? {
                        'videoId': exercise.videoId,
                        'title': exercise.name,
                        'channelTitle': 'Nurai Egzersiz',
                      }
                    : null;
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
                              videoId: video['videoId']?.toString() ?? '',
                            );
                            // Store video data in provider before navigating
                            // so VideoPlayerScreen can read it without relying
                            // on state.extra (which breaks deep links).
                            ref.read(videoPlayerDataProvider.notifier).state = {
                              'videoId': video['videoId'],
                              'title': video['title'],
                              'channel': video['channelTitle'],
                            };
                            context.go(AppRoutes.videoPlayer);
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
            // Banner Ad — sadece ücretsiz kullanıcılara
            if (!isPremium) const _BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}

// ── Banner Ad Widget ───────────────────────────────────────────────────────────

class _BannerAdWidget extends ConsumerStatefulWidget {
  const _BannerAdWidget();

  @override
  ConsumerState<_BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<_BannerAdWidget> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = ref.read(adServiceProvider).createBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _bannerAd;
    if (ad == null) return const SizedBox.shrink();
    return Container(
      alignment: Alignment.center,
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
