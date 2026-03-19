import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralised, encrypted profile storage.
///
/// Sensitive health data (age, weight, height, injuries, goals) is written to
/// [FlutterSecureStorage] (Android Keystore / iOS Keychain).
/// Non-sensitive flags (e.g. `isProfileComplete`) remain in SharedPreferences.
///
/// Migration: on first read after an app update that added secure storage,
/// data found in SharedPreferences is moved to the secure store and the old
/// plain-text keys are removed.
class ProfileService {
  static const FlutterSecureStorage _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ─── Storage keys ─────────────────────────────────────────────────────────

  static const String _kProfile = 'secure_user_profile';
  static const String _kFitnessLevel = 'fitness_level';

  // Legacy SharedPreferences keys that must be migrated then removed.
  static const List<String> _kLegacyKeys = [
    'userProfile',
    'age',
    'gender',
    'height_cm',
    'weight_kg',
    'fitness_level',
    'past_injuries',
    'other_injury',
    'goal',
  ];

  // ─── Write ────────────────────────────────────────────────────────────────

  /// Persists the full profile JSON blob and individual fitness_level key.
  static Future<void> saveProfile(Map<String, dynamic> profile) async {
    await _secure.write(key: _kProfile, value: jsonEncode(profile));
    final level = profile['fitnessLevel']?.toString() ?? '';
    if (level.isNotEmpty) {
      await _secure.write(key: _kFitnessLevel, value: level);
    }

    // Mark profile complete in SharedPreferences (non-sensitive flag).
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isProfileComplete', true);
  }

  // ─── Read ─────────────────────────────────────────────────────────────────

  /// Returns the stored profile map. Returns an empty map if nothing is saved.
  /// Automatically runs a one-time migration from SharedPreferences if needed.
  static Future<Map<String, dynamic>> loadProfile() async {
    // Migration: if secure store is empty but SharedPreferences has data, migrate.
    final existing = await _secure.read(key: _kProfile);
    if (existing == null) {
      await _migrateFromSharedPreferences();
    }

    final raw = await _secure.read(key: _kProfile);
    if (raw == null) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[ProfileService] Profile decode error: $e');
      return {};
    }
  }

  /// Returns the stored fitness level, defaulting to `'beginner'`.
  static Future<String> loadFitnessLevel() async {
    // Try secure store first; fall back to profile blob.
    final direct = await _secure.read(key: _kFitnessLevel);
    if (direct != null && direct.isNotEmpty) return direct;

    final profile = await loadProfile();
    final fromBlob = profile['fitnessLevel']?.toString() ?? '';
    return fromBlob.isNotEmpty ? fromBlob : 'beginner';
  }

  // ─── Delete ───────────────────────────────────────────────────────────────

  /// Removes all secure profile data (used on sign-out).
  static Future<void> clearProfile() async {
    await _secure.delete(key: _kProfile);
    await _secure.delete(key: _kFitnessLevel);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isProfileComplete');
  }

  // ─── Migration ────────────────────────────────────────────────────────────

  /// One-time migration: copies plain-text SharedPreferences data into the
  /// secure store, then deletes the original plain-text keys.
  static Future<void> _migrateFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('userProfile');
    if (raw == null) return; // nothing to migrate

    try {
      final profile = jsonDecode(raw) as Map<String, dynamic>;
      await saveProfile(profile);

      // Remove all legacy plain-text keys.
      for (final key in _kLegacyKeys) {
        await prefs.remove(key);
      }
      debugPrint('[ProfileService] Migration from SharedPreferences complete.');
    } catch (e) {
      debugPrint('[ProfileService] Migration failed: $e');
    }
  }
}
