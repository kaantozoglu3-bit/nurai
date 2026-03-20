import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/analysis_model.dart';
import '../../data/services/history_service.dart';

/// Fetches the user's last 20 analyses from Firestore.
/// Invalidate this provider after saving a new analysis to trigger a refresh.
final historyProvider = FutureProvider<List<AnalysisModel>>((ref) async {
  return HistoryService.fetchHistory();
});
