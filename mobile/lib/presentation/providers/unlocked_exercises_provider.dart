import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks exercises unlocked today via rewarded ads.
/// Stored in SharedPreferences, keyed by date so it resets daily.
class UnlockedExercisesNotifier extends StateNotifier<Set<String>> {
  UnlockedExercisesNotifier() : super(const {}) {
    _load();
  }

  static String _todayKey() {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return 'ad_unlocked_$date';
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_todayKey()) ?? [];
    state = raw.toSet();
  }

  Future<void> unlock(String exerciseId) async {
    final updated = {...state, exerciseId};
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_todayKey(), updated.toList());
  }

  bool isUnlocked(String exerciseId) => state.contains(exerciseId);
}

final unlockedExercisesProvider =
    StateNotifierProvider<UnlockedExercisesNotifier, Set<String>>(
  (ref) => UnlockedExercisesNotifier(),
);
