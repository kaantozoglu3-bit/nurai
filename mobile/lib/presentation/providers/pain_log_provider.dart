import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/pain_log_model.dart';
import '../../data/services/pain_log_service.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class PainLogScreenState {
  final List<PainLogModel> logs;
  final PainLogModel? todayLog;
  final int sliderValue; // 1-10
  final bool isSaving;
  final bool savedToday;

  const PainLogScreenState({
    this.logs = const [],
    this.todayLog,
    this.sliderValue = 5,
    this.isSaving = false,
    this.savedToday = false,
  });

  PainLogScreenState copyWith({
    List<PainLogModel>? logs,
    PainLogModel? todayLog,
    int? sliderValue,
    bool? isSaving,
    bool? savedToday,
  }) =>
      PainLogScreenState(
        logs: logs ?? this.logs,
        todayLog: todayLog ?? this.todayLog,
        sliderValue: sliderValue ?? this.sliderValue,
        isSaving: isSaving ?? this.isSaving,
        savedToday: savedToday ?? this.savedToday,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class PainLogNotifier extends AutoDisposeAsyncNotifier<PainLogScreenState> {
  @override
  Future<PainLogScreenState> build() async {
    final results = await Future.wait([
      PainLogService.getLast14Days(),
      PainLogService.getToday(),
    ]);

    final logs = results[0] as List<PainLogModel>;
    final todayLog = results[1] as PainLogModel?;

    return PainLogScreenState(
      logs: logs,
      todayLog: todayLog,
      sliderValue: todayLog?.score ?? 5,
      savedToday: todayLog != null,
    );
  }

  void updateSlider(int value) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data(current.copyWith(sliderValue: value));
  }

  Future<void> saveToday() async {
    final current = state.valueOrNull;
    if (current == null || current.isSaving) return;

    state = AsyncValue.data(current.copyWith(isSaving: true));

    try {
      await PainLogService.saveToday(current.sliderValue);
      // Reload logs to include newly saved entry
      final logs = await PainLogService.getLast14Days();
      final todayLog = await PainLogService.getToday();
      state = AsyncValue.data(PainLogScreenState(
        logs: logs,
        todayLog: todayLog,
        sliderValue: current.sliderValue,
        isSaving: false,
        savedToday: true,
      ));
    } catch (e) {
      state = AsyncValue.data(current.copyWith(isSaving: false));
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final painLogProvider =
    AsyncNotifierProvider.autoDispose<PainLogNotifier, PainLogScreenState>(
  PainLogNotifier.new,
);

// ─── Computed helpers ─────────────────────────────────────────────────────────

/// Streak: consecutive days with a log entry ending today.
int calculateStreak(List<PainLogModel> logs) {
  if (logs.isEmpty) return 0;
  final logDates = logs.map((l) => l.date).toSet();
  final now = DateTime.now();
  int streak = 0;
  for (int i = 0; i < 365; i++) {
    final d = now.subtract(Duration(days: i));
    final key =
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    if (logDates.contains(key)) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}

/// Improvement: (lastWeekAvg - thisWeekAvg) / lastWeekAvg * 100
/// Positive = less pain (improvement). Negative = more pain.
double calculateImprovement(List<PainLogModel> logs) {
  final now = DateTime.now();

  double avg(List<PainLogModel> subset) {
    if (subset.isEmpty) return 0;
    return subset.map((l) => l.score).reduce((a, b) => a + b) / subset.length;
  }

  final thisWeek = logs.where((l) {
    final diff = now.difference(DateTime.parse(l.date)).inDays;
    return diff < 7;
  }).toList();

  final lastWeek = logs.where((l) {
    final diff = now.difference(DateTime.parse(l.date)).inDays;
    return diff >= 7 && diff < 14;
  }).toList();

  final thisAvg = avg(thisWeek);
  final lastAvg = avg(lastWeek);

  if (lastAvg == 0 || thisWeek.isEmpty || lastWeek.isEmpty) return 0;
  return ((lastAvg - thisAvg) / lastAvg * 100);
}
