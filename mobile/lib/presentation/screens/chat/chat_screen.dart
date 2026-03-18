import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/analysis_model.dart';
import '../../../data/services/analysis_parser_service.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/quota_service.dart';
import '../../providers/auth_provider.dart';

class _ChatMessage {
  final String role;
  String content;
  bool isStreaming;

  _ChatMessage({
    required this.role,
    required this.content,
    this.isStreaming = false,
  });
}

class ChatScreen extends ConsumerStatefulWidget {
  final String bodyArea;

  const ChatScreen({super.key, required this.bodyArea});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  final _inputController = TextEditingController();
  final List<_ChatMessage> _messages = [];

  // Conversation history sent to API: [{role, content}]
  final List<Map<String, String>> _history = [];

  static const int _maxUserTurns = 6;

  static const Map<String, String> _bodyAreaLabels = {
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

  bool _isLoading = false;
  bool _analysisComplete = false;
  bool _isNavigating = false;

  // Throttle stream setState to max once per 50ms
  Timer? _streamThrottle;
  bool _pendingUpdate = false;

  // Quick replies per step (index tracks which step we're on)
  int _stepIndex = 0;
  static const _quickReplies = [
    ['Bugün başladı', 'Bu hafta içinde', '1 aydan uzun süredir', '6 aydan uzun'],
    ['1-3 (Hafif)', '4-6 (Orta)', '7-9 (Şiddetli)', '10 (Dayanılmaz)'],
    ['Yanma', 'Zonklama', 'Baskı / Sertlik', 'Uyuşma / Karıncalanma'],
    ['Hareket ederken', 'Dinlenirken', 'Sabahları', 'Geceleri'],
    ['Evet, düştüm', 'Evet, yoğun antrenman yaptım', 'Hayır, özel bir şey olmadı'],
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile().then((_) => _startConversation());
  }

  Map<String, dynamic> _buildProfile() {
    final user = ref.read(currentUserProvider);
    final saved = _savedProfile;
    return {
      'age': saved['age']?.toString() ?? 'Unknown',
      'gender': saved['gender']?.toString() ?? 'Unknown',
      'height': saved['height']?.toString() ?? 'Unknown',
      'weight': saved['weight']?.toString() ?? 'Unknown',
      'fitnessLevel': saved['fitnessLevel']?.toString() ?? 'Unknown',
      'pastInjuries': (saved['injuries'] as List?)?.cast<String>() ?? <String>[],
      'goal': saved['goal']?.toString() ?? 'Pain relief and recovery',
      'displayName': user?.displayName ?? 'User',
    };
  }

  Map<String, dynamic> _savedProfile = {};

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('userProfile');
    if (raw != null) {
      setState(() => _savedProfile = jsonDecode(raw) as Map<String, dynamic>);
    }
  }

  Future<void> _startConversation() async {
    // Check daily quota
    final canStart = await QuotaService.canStartAnalysis();
    if (!canStart && mounted) {
      context.go(AppRoutes.paywall);
      return;
    }
    await QuotaService.recordUsage();

    final areaLabel = _bodyAreaLabels[widget.bodyArea] ?? widget.bodyArea;
    final openingPrompt =
        'Merhaba Nurai! $areaLabel bölgemde ağrı yaşıyorum, yardımını istiyorum.';

    _history.add({'role': 'user', 'content': openingPrompt});
    await _streamFromAPI();
  }

  Future<void> _streamFromAPI() async {
    final aiMsg = _ChatMessage(role: 'assistant', content: '', isStreaming: true);
    setState(() {
      _isLoading = true;
      _messages.add(aiMsg);
    });
    _scrollToBottom();

    try {
      final stream = ApiService.streamChat(
        profile: _buildProfile(),
        bodyArea: widget.bodyArea,
        messages: _history,
      );

      await for (final chunk in stream) {
        aiMsg.content += chunk;
        if (mounted && !_pendingUpdate) {
          _pendingUpdate = true;
          _streamThrottle = Timer(const Duration(milliseconds: 50), () {
            if (mounted) {
              setState(() {});
              _scrollToBottom();
            }
            _pendingUpdate = false;
          });
        }
      }
      // Render final state after stream ends
      _streamThrottle?.cancel();
      _pendingUpdate = false;
      if (mounted) setState(() {});

      // Add completed AI message to history
      _history.add({'role': 'assistant', 'content': aiMsg.content});
    } catch (e) {
      debugPrint('[ChatScreen] streamChat error: $e');
      if (mounted) {
        setState(() {
          aiMsg.content = 'Bağlantı hatası. Lütfen internet bağlantınızı kontrol edin.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          aiMsg.isStreaming = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading || _analysisComplete) return;

    _inputController.clear();
    setState(() {
      _messages.add(_ChatMessage(role: 'user', content: text));
      _stepIndex++;
    });
    _history.add({'role': 'user', 'content': text});
    _scrollToBottom();

    // After _maxUserTurns turns, mark analysis complete and navigate
    if (_history.where((m) => m['role'] == 'user').length >= _maxUserTurns) {
      setState(() => _analysisComplete = true);
      await _streamFromAPI();

      if (!mounted) return;
      setState(() => _isNavigating = true);
      try {
        await Future.delayed(const Duration(milliseconds: 1200));

        if (mounted) {
          final lastAiMsg = _history.lastWhere(
            (m) => m['role'] == 'assistant',
            orElse: () => {'content': ''},
          )['content'] ?? '';

          final exercises = AnalysisParserService.parseExercises(lastAiMsg);
          final analysis = _buildAnalysisModel(lastAiMsg, exercises);

          context.go(AppRoutes.analysisResult, extra: {
            'analysis': analysis,
            'bodyArea': widget.bodyArea,
            'bodyAreaLabel': _bodyAreaLabels[widget.bodyArea] ?? widget.bodyArea,
            'exercises': exercises,
          });
        }
      } finally {
        if (mounted) setState(() => _isNavigating = false);
      }
    } else {
      await _streamFromAPI();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Builds a real AnalysisModel from the completed conversation.
  AnalysisModel _buildAnalysisModel(String lastAiMsg, List<String> exerciseNames) {
    final bodyAreaLabel = _bodyAreaLabels[widget.bodyArea] ?? widget.bodyArea;
    return AnalysisParserService.buildAnalysisModel(
      lastAiMsg: lastAiMsg,
      exerciseNames: exerciseNames,
      bodyArea: widget.bodyArea,
      bodyAreaLabel: bodyAreaLabel,
      history: _history,
    );
  }

  @override
  void dispose() {
    _streamThrottle?.cancel();
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final replies = _stepIndex < _quickReplies.length ? _quickReplies[_stepIndex] : <String>[];

    return PopScope(
      canPop: !_isNavigating,
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => context.go(AppRoutes.bodySelector),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.self_improvement,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nurai',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Fizyoterapi Asistanı',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) =>
                      _ChatBubble(message: _messages[index]),
                ),
              ),

              // Quick replies
              if (replies.isNotEmpty && !_isLoading)
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: replies.length,
                    separatorBuilder: (_, sep) => const SizedBox(width: 8),
                    itemBuilder: (context, i) => GestureDetector(
                      onTap: () => _sendMessage(replies[i]),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusFull),
                          border: Border.all(color: AppColors.primary, width: 1),
                        ),
                        child: Text(
                          replies[i],
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),

              // Input bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                  vertical: AppDimensions.paddingM,
                ),
                color: AppColors.surface,
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          decoration: InputDecoration(
                            hintText: 'Mesajınızı yazın...',
                            hintStyle: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: AppColors.textHint,
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          onSubmitted: _sendMessage,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _isLoading ? null : () => _sendMessage(_inputController.text),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _isLoading
                                ? AppColors.border
                                : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isLoading
                                ? Icons.hourglass_empty
                                : Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Analiz hazırlanıyor overlay
          if (_isNavigating)
            Container(
              color: Colors.black.withValues(alpha: 0.45),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      'Analiz hazırlanıyor...',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.self_improvement,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingM,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.chatUserBubble
                    : AppColors.chatAIBubble,
                borderRadius: BorderRadius.only(
                  topLeft:
                      const Radius.circular(AppDimensions.radiusM),
                  topRight:
                      const Radius.circular(AppDimensions.radiusM),
                  bottomLeft: Radius.circular(
                      isUser ? AppDimensions.radiusM : 4),
                  bottomRight: Radius.circular(
                      isUser ? 4 : AppDimensions.radiusM),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      message.content.isEmpty && message.isStreaming
                          ? '...'
                          : message.content,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: isUser
                            ? Colors.white
                            : AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  if (message.isStreaming) ...[
                    const SizedBox(width: 6),
                    _TypingIndicator(),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 36),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
