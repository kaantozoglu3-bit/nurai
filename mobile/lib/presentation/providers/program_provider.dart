import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/weekly_program_model.dart';
import '../../data/services/history_service.dart';
import '../../data/services/pain_log_service.dart';
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
        fitnessLevel: fitnessLevel,
      );

      state = AsyncValue.data(ProgramState(program: program));
    } catch (e) {
      final errMsg = e.toString().contains('Backend')
          ? 'Program oluşturulamadı. Lütfen tekrar deneyin.'
          : 'Bağlantı hatası. İnternet bağlantınızı kontrol edin.';
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

final fitnessLevelProvider = Provider.autoDispose<String>((ref) {
  ref.watch(currentUserProvider);
  // fitnessLevel is stored in user profile — default to 'beginner'
  return 'beginner';
});
