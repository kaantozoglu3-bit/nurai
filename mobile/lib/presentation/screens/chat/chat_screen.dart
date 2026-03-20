import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../providers/chat_provider.dart';
import '../../providers/navigation_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String bodyArea;

  const ChatScreen({super.key, required this.bodyArea});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  final _inputController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
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

  void _submit() {
    final text = _inputController.text;
    _inputController.clear();
    ref.read(chatProvider(widget.bodyArea).notifier).sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider(widget.bodyArea));
    final replies = state.stepIndex < kQuickReplies.length
        ? kQuickReplies[state.stepIndex]
        : <String>[];

    // Side-effect listeners: navigation + auto-scroll
    ref.listen(chatProvider(widget.bodyArea), (prev, next) {
      if (next.quotaExceeded && !(prev?.quotaExceeded ?? false)) {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Günlük Limitine Ulaştın',
                style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
            content: const Text(
              'Ücretsiz kullanıcılar günde 1 analiz yapabilir.\n\n'
              'Premium\'a geçerek sınırsız analiz, kişisel program ve daha fazlasına eriş.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () { Navigator.pop(context); context.go(AppRoutes.home); },
                child: const Text('Geri Dön'),
              ),
              ElevatedButton(
                onPressed: () { Navigator.pop(context); context.go(AppRoutes.paywall); },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, elevation: 0),
                child: const Text('Premium\'a Geç',
                    style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
        return;
      }
      if (next.completedAnalysis != null && prev?.completedAnalysis == null) {
        // Store data in provider before navigating — avoids state.extra
        // dependency that breaks deep links.
        ref.read(analysisResultDataProvider.notifier).state = {
          'analysis': next.completedAnalysis,
          'bodyArea': widget.bodyArea,
          'bodyAreaLabel': kBodyAreaLabels[widget.bodyArea] ?? widget.bodyArea,
        };
        context.go(AppRoutes.analysisResult);
        return;
      }
      if (next.messages.length != (prev?.messages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    return PopScope(
      canPop: !state.isNavigating,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.textPrimary, size: 20),
            onPressed: () => context.go(AppRoutes.bodySelector),
          ),
          title: const Row(
            children: [
              _AvatarIcon(),
              SizedBox(width: 10),
              Column(
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
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) =>
                        _ChatBubble(message: state.messages[index]),
                  ),
                ),

                // Retry button after connection error
                if (state.hasConnectionError && !state.isLoading)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                    child: OutlinedButton.icon(
                      onPressed: () => ref.read(chatProvider(widget.bodyArea).notifier).retryLastMessage(),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Tekrar Dene',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),

                // Quick replies
                if (replies.isNotEmpty && !state.isLoading)
                  SizedBox(
                    height: 44,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingL),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: replies.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, i) => GestureDetector(
                          onTap: () => ref
                              .read(chatProvider(widget.bodyArea).notifier)
                              .sendMessage(replies[i]),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull),
                              border: Border.all(
                                  color: AppColors.primary, width: 1),
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
                                  horizontal: 16, vertical: 10),
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
                            onSubmitted: (_) => _submit(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: state.isLoading ? null : _submit,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: state.isLoading
                                  ? AppColors.border
                                  : AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              state.isLoading
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
            if (state.isNavigating)
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

// ─── Local widgets ────────────────────────────────────────────────────────────

class _AvatarIcon extends StatelessWidget {
  const _AvatarIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.self_improvement,
          color: AppColors.primary, size: 20),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

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
                  topLeft: const Radius.circular(AppDimensions.radiusM),
                  topRight: const Radius.circular(AppDimensions.radiusM),
                  bottomLeft:
                      Radius.circular(isUser ? AppDimensions.radiusM : 4),
                  bottomRight:
                      Radius.circular(isUser ? 4 : AppDimensions.radiusM),
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
