import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/exercise_library_data.dart';
import '../../data/models/exercise_library_model.dart';
import '../../data/services/quick_exercise_service.dart';

// ─── Daily exercise selection ─────────────────────────────────────────────────

/// Returns 3 "Kolay" exercises for today, deterministically derived from
/// the day-of-year so the same set shows all day and changes overnight.
List<ExerciseLibraryItem> getTodayExercises() {
  final dayOfYear = _dayOfYear(DateTime.now());

  // Pick a body area based on day (rotates through all 15 areas)
  final areaIndex = dayOfYear % exerciseLibrary.length;
  final area = exerciseLibrary[areaIndex];

  // Prefer "Kolay" exercises; fall back to any if not enough
  final easy = area.exercises.where((e) => e.difficulty == 'Kolay').toList();
  final pool = easy.length >= 3 ? easy : area.exercises;

  // Deterministic shuffle using dayOfYear as seed
  final selected = List<ExerciseLibraryItem>.from(pool);
  selected.sort((a, b) {
    final ai = (a.name.codeUnitAt(0) + dayOfYear) % 100;
    final bi = (b.name.codeUnitAt(0) + dayOfYear) % 100;
    return ai.compareTo(bi);
  });

  return selected.take(3).toList();
}

String getTodayAreaLabel() {
  final dayOfYear = _dayOfYear(DateTime.now());
  final areaIndex = dayOfYear % exerciseLibrary.length;
  return exerciseLibrary[areaIndex].label;
}

int _dayOfYear(DateTime d) {
  return d.difference(DateTime(d.year, 1, 1)).inDays;
}

// ─── State ────────────────────────────────────────────────────────────────────

class QuickExerciseState {
  final bool isDoneToday;
  final bool isLoading;

  const QuickExerciseState({this.isDoneToday = false, this.isLoading = true});

  QuickExerciseState copyWith({bool? isDoneToday, bool? isLoading}) =>
      QuickExerciseState(
        isDoneToday: isDoneToday ?? this.isDoneToday,
        isLoading: isLoading ?? this.isLoading,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class QuickExerciseNotifier
    extends AutoDisposeNotifier<QuickExerciseState> {
  @override
  QuickExerciseState build() {
    _load();
    return const QuickExerciseState();
  }

  Future<void> _load() async {
    final done = await QuickExerciseService.isDoneToday();
    state = state.copyWith(isDoneToday: done, isLoading: false);
  }

  Future<void> markComplete() async {
    await QuickExerciseService.markDoneToday();
    state = state.copyWith(isDoneToday: true);
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final quickExerciseProvider =
    NotifierProvider.autoDispose<QuickExerciseNotifier, QuickExerciseState>(
  QuickExerciseNotifier.new,
);
