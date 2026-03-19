import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../../core/constants/firestore_paths.dart';
import '../models/weekly_program_model.dart';
import 'api_service.dart';

class ProgramService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ─── Firestore paths ────────────────────────────────────────────────────────

  static DocumentReference<Map<String, dynamic>> _programDoc(String uid) =>
      _db.doc(FirestorePaths.program(uid));

  // ─── Load from Firestore ────────────────────────────────────────────────────

  /// Returns the saved program or null if none exists yet.
  static Future<WeeklyProgramModel?> loadProgram() async {
    final uid = _uid;
    if (uid == null) return null;

    try {
      final snap = await _programDoc(uid).get();
      if (!snap.exists || snap.data() == null) return null;
      return WeeklyProgramModel.fromMap(snap.data()!);
    } catch (e) {
      debugPrint('[ProgramService] loadProgram error: $e');
      return null;
    }
  }

  // ─── Generate via backend ───────────────────────────────────────────────────

  /// Calls the backend to generate a 4-week program, then saves to Firestore.
  static Future<WeeklyProgramModel> generateAndSave({
    required List<String> targetAreas,
    required double avgPainScore,
    required String fitnessLevel,
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('User not authenticated');

    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();

    final dio = Dio(BaseOptions(
      baseUrl: ApiService.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 90),
      responseType: ResponseType.json,
    ));

    final response = await dio.post<Map<String, dynamic>>(
      '/api/v1/program/generate',
      data: {
        'targetAreas': targetAreas,
        'avgPainScore': avgPainScore,
        'fitnessLevel': fitnessLevel,
      },
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
    );

    final programData = response.data?['program'] as Map<String, dynamic>?;
    if (programData == null) {
      throw Exception('Backend did not return program data');
    }

    final program = WeeklyProgramModel(
      generatedAt: DateTime.now(),
      targetAreas: targetAreas,
      weeks: (programData['weeks'] as List? ?? [])
          .map((w) => ProgramWeek.fromMap(Map<String, dynamic>.from(w as Map)))
          .toList(),
      completedDays: const [],
    );

    await _programDoc(uid).set(program.toMap());
    return program;
  }

  // ─── Completion tracking ────────────────────────────────────────────────────

  /// Marks a day as completed (or uncompleted if already done — toggle).
  static Future<WeeklyProgramModel?> toggleDayCompletion(
    WeeklyProgramModel current,
    int weekNumber,
    int dayNumber,
  ) async {
    final uid = _uid;
    if (uid == null) return null;

    final key = WeeklyProgramModel.dayKey(weekNumber, dayNumber);
    final newList = List<String>.from(current.completedDays);
    if (newList.contains(key)) {
      newList.remove(key);
    } else {
      newList.add(key);
    }

    final updated = current.copyWith(completedDays: newList);
    await _programDoc(uid).update({'completedDays': newList});
    return updated;
  }
}
