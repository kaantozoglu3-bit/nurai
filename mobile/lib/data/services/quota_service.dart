import 'package:shared_preferences/shared_preferences.dart';

/// Tracks daily free analysis quota (3 per day for free users).
class QuotaService {
  static const int _dailyLimit = 3;
  static const String _countKey = 'quota_count';
  static const String _dateKey = 'quota_date';

  /// Returns remaining free uses today.
  static Future<int> getRemainingUses() async {
    final prefs = await SharedPreferences.getInstance();
    _resetIfNewDay(prefs);
    final used = prefs.getInt(_countKey) ?? 0;
    return (_dailyLimit - used).clamp(0, _dailyLimit);
  }

  /// Returns true if user can start a new analysis.
  static Future<bool> canStartAnalysis() async {
    return (await getRemainingUses()) > 0;
  }

  /// Increments the daily usage counter. Call when a chat session starts.
  static Future<void> recordUsage() async {
    final prefs = await SharedPreferences.getInstance();
    _resetIfNewDay(prefs);
    final used = prefs.getInt(_countKey) ?? 0;
    await prefs.setInt(_countKey, used + 1);
  }

  static void _resetIfNewDay(SharedPreferences prefs) {
    final today = _todayString();
    final saved = prefs.getString(_dateKey) ?? '';
    if (saved != today) {
      prefs.setInt(_countKey, 0);
      prefs.setString(_dateKey, today);
    }
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
