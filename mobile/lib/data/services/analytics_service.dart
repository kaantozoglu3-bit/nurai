import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logAnalysisStarted(String bodyArea) async {
    await _analytics.logEvent(
      name: 'analysis_started',
      parameters: {'body_area': bodyArea},
    );
  }

  Future<void> logAnalysisCompleted({
    required String bodyArea,
    required int painScore,
    required int exerciseCount,
  }) async {
    await _analytics.logEvent(
      name: 'analysis_completed',
      parameters: {
        'body_area': bodyArea,
        'pain_score': painScore,
        'exercise_count': exerciseCount,
      },
    );
  }

  Future<void> logBodyAreaSelected(String bodyArea) async {
    await _analytics.logEvent(
      name: 'body_area_selected',
      parameters: {'body_area': bodyArea},
    );
  }

  Future<void> logPaywallViewed(String trigger) async {
    await _analytics.logEvent(
      name: 'paywall_viewed',
      parameters: {'trigger': trigger},
    );
  }

  Future<void> logExerciseVideoWatched({
    required String exerciseName,
    required String videoId,
  }) async {
    await _analytics.logEvent(
      name: 'exercise_video_watched',
      parameters: {'exercise_name': exerciseName, 'video_id': videoId},
    );
  }

  Future<void> logAnalysisShared(String bodyArea) async {
    await _analytics.logEvent(
      name: 'analysis_shared',
      parameters: {'body_area': bodyArea},
    );
  }

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }
}
