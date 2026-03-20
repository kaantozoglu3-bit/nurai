import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/firestore_paths.dart';
import '../models/analysis_model.dart';

/// Saves and fetches user analyses from Firestore.
/// Collection path: users/{uid}/analyses
class HistoryService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>> get _col {
    final uid = _uid;
    if (uid == null) throw StateError('User not authenticated');
    return _db.collection(FirestorePaths.userAnalyses(uid));
  }

  /// Saves an analysis to Firestore. Uses analysis.id as the document ID.
  static Future<void> saveAnalysis(AnalysisModel analysis) async {
    await _col.doc(analysis.id).set(_toMap(analysis));
  }

  /// Returns the last 20 analyses ordered by createdAt descending.
  static Future<List<AnalysisModel>> fetchHistory() async {
    final snap = await _col
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();
    return snap.docs.map((d) => _fromMap(d.id, d.data())).toList();
  }

  // ── Serialisation ──────────────────────────────────────────────────────────

  static Map<String, dynamic> _toMap(AnalysisModel a) => {
        'bodyArea': a.bodyArea,
        'bodyAreaLabel': a.bodyAreaLabel,
        'painScore': a.painScore,
        'userComplaint': a.userComplaint,
        'aiSummary': a.aiSummary,
        'possibleCauses': a.possibleCauses,
        'exercises': a.exercises
            .map((e) => {
                  'name': e.name,
                  'description': e.description,
                  'difficulty': e.difficulty,
                  'duration': e.duration,
                  if (e.videoId != null) 'videoId': e.videoId,
                })
            .toList(),
        'createdAt': Timestamp.fromDate(a.createdAt),
      };

  static AnalysisModel _fromMap(String id, Map<String, dynamic> d) {
    final exercises = (d['exercises'] as List? ?? [])
        .map((e) => ExerciseModel(
              name: e['name'] as String? ?? '',
              description: e['description'] as String? ?? '',
              difficulty: e['difficulty'] as String? ?? 'Orta',
              duration: e['duration'] as String? ?? '3 set x 10 tekrar',
              videoId: e['videoId'] as String?,
            ))
        .toList();

    final ts = d['createdAt'];
    final createdAt = ts is Timestamp
        ? ts.toDate()
        : DateTime.tryParse(ts?.toString() ?? '') ?? DateTime.now();

    return AnalysisModel(
      id: id,
      bodyArea: d['bodyArea'] as String? ?? '',
      bodyAreaLabel: d['bodyAreaLabel'] as String? ?? '',
      painScore: (d['painScore'] as num?)?.toInt() ?? 5,
      userComplaint: d['userComplaint'] as String? ?? '',
      aiSummary: d['aiSummary'] as String? ?? '',
      possibleCauses: List<String>.from(d['possibleCauses'] as List? ?? []),
      exercises: exercises,
      videos: [],
      createdAt: createdAt,
    );
  }
}
