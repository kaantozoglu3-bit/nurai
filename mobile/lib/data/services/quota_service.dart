import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Tracks daily free analysis quota (3 per day for free users — freemium tier).
/// Must match backend FREE_DAILY_LIMIT env var (default 3).
/// Uses flutter_secure_storage with encrypted Android shared preferences.
class QuotaService {
  static const int dailyLimit = 3;

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static String get _uid =>
      FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

  static String get _countKey => 'quota_count_$_uid';
  static String get _dateKey => 'quota_date_$_uid';

  /// Returns remaining free uses today.
  static Future<int> getRemainingUses() async {
    await _resetIfNewDay();
    final countStr = await _storage.read(key: _countKey);
    final used = int.tryParse(countStr ?? '0') ?? 0;
    return (dailyLimit - used).clamp(0, dailyLimit);
  }

  /// Returns true if user can start a new analysis.
  static Future<bool> canStartAnalysis() async {
    return (await getRemainingUses()) > 0;
  }

  /// Increments the daily usage counter. Call when a chat session starts.
  static Future<void> recordUsage() async {
    await _resetIfNewDay();
    final countStr = await _storage.read(key: _countKey);
    final used = int.tryParse(countStr ?? '0') ?? 0;
    await _storage.write(key: _countKey, value: (used + 1).toString());
  }

  /// Clears quota cache for the current user. Call on logout.
  static Future<void> clearForCurrentUser() async {
    await _storage.delete(key: _countKey);
    await _storage.delete(key: _dateKey);
  }

  static Future<void> _resetIfNewDay() async {
    final today = _todayString();
    final saved = await _storage.read(key: _dateKey) ?? '';
    if (saved != today) {
      await _storage.write(key: _countKey, value: '0');
      await _storage.write(key: _dateKey, value: today);
    }
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
