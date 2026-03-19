import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/analysis_model.dart';
import '../../data/services/analysis_parser_service.dart';
import '../../data/services/api_service.dart';
import '../../data/services/history_service.dart';
import '../../data/services/profile_service.dart';
import '../../data/services/quota_service.dart';
import 'history_provider.dart';

// ─── Public constants ─────────────────────────────────────────────────────────

const Map<String, String> kBodyAreaLabels = {
  'neck': 'Boyun',
  'left_shoulder': 'Sol Omuz',
  'right_shoulder': 'Sağ Omuz',
  'upper_back': 'Üst Sırt / Göğüs',
  'lower_back': 'Bel / Alt Sırt',
  'hip': 'Kalça',
  'left_knee': 'Sol Diz',
  'right_knee': 'Sağ Diz',
  'left_elbow': 'Sol Dirsek',
  'right_elbow': 'Sağ Dirsek',
  'left_wrist': 'Sol Bilek',
  'right_wrist': 'Sağ Bilek',
  'left_ankle': 'Sol Ayak Bileği',
  'right_ankle': 'Sağ Ayak Bileği',
  'core': 'Karın / Core',
};

const List<List<String>> kQuickReplies = [
  ['Bugün başladı', 'Bu hafta içinde', '1 aydan uzun süredir', '6 aydan uzun'],
  ['1-3 (Hafif)', '4-6 (Orta)', '7-9 (Şiddetli)', '10 (Dayanılmaz)'],
  ['Yanma', 'Zonklama', 'Baskı / Sertlik', 'Uyuşma / Karıncalanma'],
  ['Hareket ederken', 'Dinlenirken', 'Sabahları', 'Geceleri'],
  ['Evet, düştüm', 'Evet, yoğun antrenman yaptım', 'Hayır, özel bir şey olmadı'],
];

// ─── Private constants ────────────────────────────────────────────────────────

const int _kMaxUserTurns = 6;
const Duration _kStreamThrottleDuration = Duration(milliseconds: 50);

// ─── ChatMessage ──────────────────────────────────────────────────────────────

class ChatMessage {
  final String role;
  String content;
  bool isStreaming;

  ChatMessage({
    required this.role,
    required this.content,
    this.isStreaming = false,
  });
}

// ─── ChatState ────────────────────────────────────────────────────────────────

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool analysisComplete;
  final bool isNavigating;
  final int stepIndex;
  final AnalysisModel? completedAnalysis;
  final bool quotaExceeded;
  final bool hasConnectionError;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.analysisComplete = false,
    this.isNavigating = false,
    this.stepIndex = 0,
    this.completedAnalysis,
    this.quotaExceeded = false,
    this.hasConnectionError = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? analysisComplete,
    bool? isNavigating,
    int? stepIndex,
    AnalysisModel? completedAnalysis,
    bool? quotaExceeded,
    bool? hasConnectionError,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        analysisComplete: analysisComplete ?? this.analysisComplete,
        isNavigating: isNavigating ?? this.isNavigating,
        stepIndex: stepIndex ?? this.stepIndex,
        completedAnalysis: completedAnalysis ?? this.completedAnalysis,
        quotaExceeded: quotaExceeded ?? this.quotaExceeded,
        hasConnectionError: hasConnectionError ?? this.hasConnectionError,
      );
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String generateSessionId() {
  final rng = Random.secure();
  final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}'
      '-${hex.substring(12, 16)}-${hex.substring(16, 20)}'
      '-${hex.substring(20)}';
}

// ─── SessionId helpers ────────────────────────────────────────────────────────

String _sessionKey(String bodyArea) {
  final now = DateTime.now();
  return 'session_${bodyArea}_${now.year}-${now.month}-${now.day}';
}

Future<String> _loadOrCreateSessionId(String bodyArea) async {
  final prefs = await SharedPreferences.getInstance();
  final key = _sessionKey(bodyArea);
  final existing = prefs.getString(key);
  if (existing != null) return existing;
  final fresh = generateSessionId();
  await prefs.setString(key, fresh);
  return fresh;
}

// ─── ChatNotifier ─────────────────────────────────────────────────────────────

class ChatNotifier extends AutoDisposeFamilyNotifier<ChatState, String> {
  String _sessionId = '';
  final List<Map<String, String>> _history = [];
  final List<ChatMessage> _messages = [];
  Map<String, dynamic> _savedProfile = {};
  Timer? _streamThrottle;
  bool _pendingUpdate = false;
  late String _bodyArea;

  @override
  ChatState build(String bodyArea) {
    _bodyArea = bodyArea;
    ref.onDispose(() => _streamThrottle?.cancel());
    _initialize();
    return const ChatState(isLoading: true);
  }

  // ── Initialisation ──────────────────────────────────────────────────────────

  Future<void> _initialize() async {
    _sessionId = await _loadOrCreateSessionId(_bodyArea);
    await _loadProfile();
    await _startConversation();
  }

  Future<void> _loadProfile() async {
    _savedProfile = await ProfileService.loadProfile();
  }

  Map<String, dynamic> _buildProfile() {
    final saved = _savedProfile;
    return {
      'age': saved['age']?.toString() ?? 'Unknown',
      'gender': saved['gender']?.toString() ?? 'Unknown',
      'height': saved['height']?.toString() ?? 'Unknown',
      'weight': saved['weight']?.toString() ?? 'Unknown',
      'fitnessLevel': saved['fitnessLevel']?.toString() ?? 'Unknown',
      'pastInjuries': (saved['injuries'] as List?)?.cast<String>() ?? <String>[],
      'goal': saved['goal']?.toString() ?? 'Pain relief and recovery',
    };
  }

  Future<void> _startConversation() async {
    final canStart = await QuotaService.canStartAnalysis();
    if (!canStart) {
      state = state.copyWith(quotaExceeded: true, isLoading: false);
      return;
    }
    await QuotaService.recordUsage();

    final areaLabel = kBodyAreaLabels[_bodyArea] ?? _bodyArea;
    final openingPrompt =
        'Merhaba Nurai! $areaLabel bölgemde ağrı yaşıyorum, yardımını istiyorum.';

    _history.add({'role': 'user', 'content': openingPrompt});
    await _streamFromAPI();
  }

  // ── Streaming ───────────────────────────────────────────────────────────────

  Future<void> _streamFromAPI() async {
    final aiMsg = ChatMessage(role: 'assistant', content: '', isStreaming: true);
    _messages.add(aiMsg);
    state = state.copyWith(isLoading: true, messages: List.unmodifiable(_messages));

    try {
      final stream = ApiService.streamChat(
        profile: _buildProfile(),
        bodyArea: _bodyArea,
        messages: _history,
        sessionId: _sessionId,
      );

      await for (final chunk in stream) {
        aiMsg.content += chunk;
        if (!_pendingUpdate) {
          _pendingUpdate = true;
          _streamThrottle = Timer(_kStreamThrottleDuration, () {
            state = state.copyWith(messages: List.unmodifiable(_messages));
            _pendingUpdate = false;
          });
        }
      }

      _streamThrottle?.cancel();
      _pendingUpdate = false;
      _history.add({'role': 'assistant', 'content': aiMsg.content});
    } catch (e) {
      aiMsg.content = 'Bağlantı hatası. Lütfen internet bağlantınızı kontrol edin.';
      debugPrint('[ChatNotifier] streamFromAPI hatası: $e');
      state = state.copyWith(hasConnectionError: true);
    } finally {
      aiMsg.isStreaming = false;
      state = state.copyWith(
        isLoading: false,
        messages: List.unmodifiable(_messages),
      );
    }
  }

  /// Retries the last failed AI response by re-streaming from the current history.
  Future<void> retryLastMessage() async {
    if (state.isLoading) return;
    // Remove the last error message from the visible list
    if (_messages.isNotEmpty && _messages.last.role == 'assistant') {
      _messages.removeLast();
    }
    state = state.copyWith(
      hasConnectionError: false,
      messages: List.unmodifiable(_messages),
    );
    await _streamFromAPI();
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isLoading || state.analysisComplete) return;
    if (text.length > 2000) return; // Prevent oversized messages

    _messages.add(ChatMessage(role: 'user', content: text));
    _history.add({'role': 'user', 'content': text});
    state = state.copyWith(
      messages: List.unmodifiable(_messages),
      stepIndex: state.stepIndex + 1,
    );

    final userTurns = _history.where((m) => m['role'] == 'user').length;

    if (userTurns >= _kMaxUserTurns) {
      state = state.copyWith(analysisComplete: true);
      await _streamFromAPI();

      state = state.copyWith(isNavigating: true);
      await Future.delayed(const Duration(milliseconds: 1200));

      final lastAiContent = _history.lastWhere(
        (m) => m['role'] == 'assistant',
        orElse: () => {'content': ''},
      )['content'] ?? '';

      final exercises = AnalysisParserService.parseExercises(lastAiContent);
      final analysis = AnalysisParserService.buildAnalysisModel(
        lastAiMsg: lastAiContent,
        exerciseNames: exercises,
        bodyArea: _bodyArea,
        bodyAreaLabel: kBodyAreaLabels[_bodyArea] ?? _bodyArea,
        history: _history,
      );

      // Fire-and-forget Firestore save
      HistoryService.saveAnalysis(analysis)
          .then((_) => ref.invalidate(historyProvider))
          .catchError((Object _) {});

      state = state.copyWith(completedAnalysis: analysis, isNavigating: false);
    } else {
      await _streamFromAPI();
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final chatProvider =
    NotifierProvider.autoDispose.family<ChatNotifier, ChatState, String>(
  ChatNotifier.new,
);
