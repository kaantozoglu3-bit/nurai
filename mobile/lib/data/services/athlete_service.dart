import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

/// Manages athlete profile and exercise-completion tracking in Firestore.
///
/// Firestore paths:
///   users/{uid}/athleteProfile  (merged document)
///   users/{uid}/athleteProgress/{date}/completedExercises (map)
class AthleteService {
  static const String _kProfileKey = 'athleteProfile';
  static const String _kProgressKey = 'athleteProgress';

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ── Athlete Profile ──────────────────────────────────────────────────────

  /// Saves / merges athlete context into Firestore user document.
  static Future<void> saveAthleteProfile({
    required String injuryType,
    required int currentPhase,
    String? sport,
    String? injuryDate,
    String? surgeryDate,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _db.collection('users').doc(uid).set(
        {
          _kProfileKey: {
            'injuryType': injuryType,
            'currentPhase': currentPhase,
            'sport': sport,
            'injuryDate': injuryDate,
            'surgeryDate': surgeryDate,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        },
        SetOptions(merge: true),
      );
      if (kDebugMode) debugPrint('[AthleteService] Profile saved: $injuryType faz$currentPhase');
    } catch (e) {
      if (kDebugMode) debugPrint('[AthleteService] saveAthleteProfile error: $e');
    }
  }

  // ── Exercise Completion ──────────────────────────────────────────────────

  /// Records a completed exercise for a given injury + phase.
  ///
  /// Path: users/{uid}/athleteProgress/{YYYY-MM-DD}
  /// Field: completedExercises.{injuryId}_phase{phase}_{exerciseName}
  static Future<void> logExerciseCompletion({
    required String injuryId,
    required int phaseNumber,
    required String exerciseName,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    final date = _todayKey();
    final fieldKey = '${injuryId}_phase${phaseNumber}_${exerciseName.replaceAll(' ', '_')}';
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection(_kProgressKey)
          .doc(date)
          .set(
        {
          'completedExercises': {
            fieldKey: FieldValue.serverTimestamp(),
          },
          'injuryId': injuryId,
          'phaseNumber': phaseNumber,
          'date': date,
        },
        SetOptions(merge: true),
      );
      if (kDebugMode) debugPrint('[AthleteService] Exercise logged: $fieldKey');
    } catch (e) {
      if (kDebugMode) debugPrint('[AthleteService] logExerciseCompletion error: $e');
    }
  }

  /// Returns the set of completed exercise field-keys for today.
  static Future<Set<String>> fetchTodayCompletions({
    required String injuryId,
    required int phaseNumber,
  }) async {
    final uid = _uid;
    if (uid == null) return {};
    try {
      final doc = await _db
          .collection('users')
          .doc(uid)
          .collection(_kProgressKey)
          .doc(_todayKey())
          .get();
      if (!doc.exists) return {};
      final raw = doc.data()?['completedExercises'] as Map<String, dynamic>?;
      if (raw == null) return {};
      final prefix = '${injuryId}_phase${phaseNumber}_';
      return raw.keys.where((k) => k.startsWith(prefix)).toSet();
    } catch (e) {
      if (kDebugMode) debugPrint('[AthleteService] fetchTodayCompletions error: $e');
      return {};
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
