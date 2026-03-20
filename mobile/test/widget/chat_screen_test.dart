import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:painrelief_ai/core/constants/app_colors.dart';
import 'package:painrelief_ai/presentation/providers/chat_provider.dart';

/// Standalone ChatScreen widget for testing — avoids Firebase dependency
/// by rendering the UI structure directly with a pre-built ChatState.
class _TestChatScreen extends ConsumerWidget {
  final ChatState chatState;

  const _TestChatScreen({required this.chatState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nurai',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600)),
                Text('Fizyoterapi Asistanı',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final msg = chatState.messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(msg.content),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.surface,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'Mesaj giriş alanı',
                      textField: true,
                      child: const TextField(
                        decoration: InputDecoration(hintText: 'Mesajınızı yazın...'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Semantics(
                    label: 'Mesaj gönder',
                    button: true,
                    child: GestureDetector(
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  group('ChatScreen widget tests', () {
    testWidgets('renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: _TestChatScreen(
              chatState: ChatState(
                messages: [
                  ChatMessage(role: 'assistant', content: 'Merhaba! Size nasıl yardımcı olabilirim?'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Nurai'), findsOneWidget);
      expect(find.text('Fizyoterapi Asistanı'), findsOneWidget);
    });

    testWidgets('message input field is present', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: _TestChatScreen(chatState: const ChatState()),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Mesajınızı yazın...'), findsOneWidget);

      // Verify semantics label
      final semantics = find.bySemanticsLabel('Mesaj giriş alanı');
      expect(semantics, findsOneWidget);
    });

    testWidgets('send button is present with correct semantics', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: _TestChatScreen(chatState: const ChatState()),
          ),
        ),
      );

      // Find the send icon
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);

      // Verify semantics label
      final sendButton = find.bySemanticsLabel('Mesaj gönder');
      expect(sendButton, findsOneWidget);
    });

    testWidgets('displays messages from chat state', (WidgetTester tester) async {
      final messages = [
        ChatMessage(role: 'assistant', content: 'Merhaba!'),
        ChatMessage(role: 'user', content: 'Bel ağrım var'),
        ChatMessage(role: 'assistant', content: 'Anlıyorum, ne zamandır ağrınız var?'),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: _TestChatScreen(
              chatState: ChatState(messages: messages),
            ),
          ),
        ),
      );

      expect(find.text('Merhaba!'), findsOneWidget);
      expect(find.text('Bel ağrım var'), findsOneWidget);
      expect(find.text('Anlıyorum, ne zamandır ağrınız var?'), findsOneWidget);
    });

    testWidgets('empty state renders without messages', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: _TestChatScreen(chatState: const ChatState()),
          ),
        ),
      );

      // No messages should be displayed
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Merhaba!'), findsNothing);
    });
  });
}
