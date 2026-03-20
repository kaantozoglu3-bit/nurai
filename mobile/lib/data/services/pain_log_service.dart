import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import '../../core/constants/firestore_paths.dart';
import '../models/pain_log_model.dart';

class PainLogService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static const int _fetchDays = 14;

  static String _today() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  /// Saves (or overwrites) today's pain log for the current user.
  static Future<void> saveToday(int score) async {
    final uid = _uid;
    if (uid == null) throw StateError('User not authenticated');

    final date = _today();
    await _db.doc(FirestorePaths.painLog(uid, date)).set(
          PainLogModel(date: date, score: score, createdAt: DateTime.now())
              .toMap(),
        );
  }

  /// Returns today's pain log, or null if not yet entered.
  static Future<PainLogModel?> getToday() async {
    final uid = _uid;
    if (uid == null) return null;

    try {
      final snap = await _db.doc(FirestorePaths.painLog(uid, _today())).get();
      if (!snap.exists || snap.data() == null) return null;
      return PainLogModel.fromMap(snap.id, snap.data()!);
    } catch (e) {
      if (kDebugMode) debugPrint('[PainLogService] getToday hatası: $e');
      return null;
    }
  }

  /// Returns pain logs for the last [_fetchDays] days (ordered newest first).
  static Future<List<PainLogModel>> getLast14Days() async {
    final uid = _uid;
    if (uid == null) return [];

    try {
      final cutoff = DateTime.now().subtract(const Duration(days: _fetchDays));
      final cutoffStr =
          '${cutoff.year.toString().padLeft(4, '0')}-'
          '${cutoff.month.toString().padLeft(2, '0')}-'
          '${cutoff.day.toString().padLeft(2, '0')}';

      final snap = await _db
          .collection(FirestorePaths.painLogs(uid))
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: cutoffStr)
          .orderBy(FieldPath.documentId, descending: true)
          .limit(_fetchDays)
          .get();

      return snap.docs
          .map((d) => PainLogModel.fromMap(d.id, d.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[PainLogService] getLast14Days hatası: $e');
      return [];
    }
  }
}
