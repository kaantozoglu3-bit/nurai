import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/physiotherapist_model.dart';
import '../../data/models/message_model.dart';

/// Holds the analysis data map passed to AnalysisResultScreen.
/// Set this provider before navigating to the analysis result route so the
/// screen can read it instead of relying on GoRouter state.extra.
final analysisResultDataProvider =
    StateProvider<Map<String, dynamic>>((ref) => const {});

/// Holds the video data map passed to VideoPlayerScreen.
/// Set this provider before navigating to the video player route.
final videoPlayerDataProvider =
    StateProvider<Map<String, dynamic>>((ref) => const {});

/// Holds the PhysiotherapistModel passed to PtDetailScreen.
/// Set this provider before navigating to the ptDetail route.
final ptDetailDataProvider =
    StateProvider<PhysiotherapistModel?>((ref) => null);

/// Holds the conversation data passed to MessagingScreen.
/// Set this provider before navigating to the messaging route.
final messagingDataProvider =
    StateProvider<ConversationModel?>((ref) => null);
