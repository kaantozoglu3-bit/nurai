import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/weekly_program_model.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/history_service.dart';
import '../../data/services/pain_log_service.dart';
import '../../data/services/profile_service.dart';
import '../../data/services/program_service.dart';
import 'auth_provider.dart';

// ─── State ────────────────────────────────────────────────────────────────────

enum ProgramStatus { idle, generating, error }

class ProgramState {
  final WeeklyProgramModel? program;
  final ProgramStatus status;
  final String? errorMessage;

  const ProgramState({
    this.program,
    this.status = ProgramStatus.idle,
    this.errorMessage,
  });

  bool get hasProgram => program != null;
  bool get isGenerating => status == ProgramStatus.generating;
  bool get hasError => status == ProgramStatus.error;

  ProgramState copyWith({
    WeeklyProgramModel? program,
    ProgramStatus? status,
    String? errorMessage,
  }) =>
      ProgramState(
        program: program ?? this.program,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class ProgramNotifier extends AutoDisposeAsyncNotifier<ProgramState> {
  @override
  Future<ProgramState> build() async {
    final program = await ProgramService.loadProgram();
    return ProgramState(program: program);
  }

  /// Maps onboarding activity keys to backend-accepted fitness level values.
  String _toBackendFitnessLevel(String level) {
    switch (level) {
      case 'sedentary':
      case 'light':
        return 'beginner';
      case 'moderate':
        return 'intermediate';
      case 'active':
        return 'advanced';
      default:
        return level; // already beginner/intermediate/advanced
    }
  }

  Future<void> generate(String fitnessLevel) async {
    final current = state.valueOrNull ?? const ProgramState();
    state = AsyncValue.data(current.copyWith(status: ProgramStatus.generating));

    try {
      // Pull last 10 analyses to find top pain areas
      final analyses = await HistoryService.fetchHistory();
      final areaCounts = <String, int>{};
      for (final a in analyses) {
        areaCounts[a.bodyArea] = (areaCounts[a.bodyArea] ?? 0) + 1;
      }
      final targetAreas = (areaCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)))
          .take(3)
          .map((e) => e.key)
          .toList();

      if (targetAreas.isEmpty) {
        // Fallback: use last analysis body area or generic
        if (analyses.isNotEmpty) {
          targetAreas.add(analyses.first.bodyArea);
        } else {
          targetAreas.add('general');
        }
      }

      // Average pain score from pain logs
      final logs = await PainLogService.getLast14Days();
      final avgPainScore = logs.isEmpty
          ? 5.0
          : logs.map((l) => l.score).reduce((a, b) => a + b) / logs.length;

      final program = await ProgramService.generateAndSave(
        targetAreas: targetAreas,
        avgPainScore: avgPainScore,
        fitnessLevel: _toBackendFitnessLevel(fitnessLevel),
      );

      await AnalyticsService.instance.logProgramGenerated();
      state = AsyncValue.data(ProgramState(program: program));
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      if (kDebugMode) debugPrint('[ProgramProvider] generate error: $e');
      final msg = e.toString();
      final errMsg = msg.contains('SocketException') || msg.contains('connection')
          ? 'Bağlantı hatası. İnternet bağlantınızı kontrol edin.'
          : msg.contains('401') || msg.contains('App Check') || msg.contains('oturum')
              ? 'Oturum hatası. Çıkış yapıp tekrar giriş yapın.'
              : msg.contains('timeout') || msg.contains('TimeoutException')
                  ? 'Sunucu yanıt vermedi. Lütfen tekrar deneyin.'
                  : 'Program oluşturulamadı. Lütfen tekrar deneyin.';
      state = AsyncValue.data(current.copyWith(
        status: ProgramStatus.error,
        errorMessage: errMsg,
      ));
    }
  }

  Future<void> toggleDay(int week, int day) async {
    final current = state.valueOrNull;
    if (current?.program == null) return;

    final updated = await ProgramService.toggleDayCompletion(
      current!.program!,
      week,
      day,
    );
    if (updated != null) {
      state = AsyncValue.data(current.copyWith(program: updated));
    }
  }

  void clearError() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(status: ProgramStatus.idle));
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final programProvider =
    AsyncNotifierProvider.autoDispose<ProgramNotifier, ProgramState>(
  ProgramNotifier.new,
);

// ─── Fitness level helper ─────────────────────────────────────────────────────

/// Reads fitnessLevel from encrypted profile storage.
/// Defaults to 'beginner' if not set.
final fitnessLevelProvider = FutureProvider.autoDispose<String>((ref) async {
  ref.watch(currentUserProvider);
  return ProfileService.loadFitnessLevel();
});
