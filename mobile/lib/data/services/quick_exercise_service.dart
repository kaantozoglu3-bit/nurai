import 'package:shared_preferences/shared_preferences.dart';

/// Tracks quick-exercise completion per calendar day.
class QuickExerciseService {
  static const String _keyPrefix = 'quick_exercise_done_';

  static String _todayKey() {
    final now = DateTime.now();
    return '$_keyPrefix${now.year}-${now.month}-${now.day}';
  }

  static Future<bool> isDoneToday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_todayKey()) ?? false;
  }

  static Future<void> markDoneToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_todayKey(), true);
  }
}
