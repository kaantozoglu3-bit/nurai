import 'package:flutter_test/flutter_test.dart';
import 'package:painrelief_ai/presentation/providers/chat_provider.dart';

void main() {
  group('ChatState', () {
    test('default constructor has empty messages', () {
      const state = ChatState();
      expect(state.messages, isEmpty);
    });

    test('default constructor has isLoading false', () {
      const state = ChatState();
      expect(state.isLoading, isFalse);
    });

    test('default constructor has analysisComplete false', () {
      const state = ChatState();
      expect(state.analysisComplete, isFalse);
    });

    test('default constructor has stepIndex 0', () {
      const state = ChatState();
      expect(state.stepIndex, 0);
    });

    test('default constructor has quotaExceeded false', () {
      const state = ChatState();
      expect(state.quotaExceeded, isFalse);
    });

    test('copyWith updates isLoading', () {
      const state = ChatState();
      final updated = state.copyWith(isLoading: true);
      expect(updated.isLoading, isTrue);
      expect(updated.messages, isEmpty); // unchanged
    });

    test('copyWith updates stepIndex', () {
      const state = ChatState();
      final updated = state.copyWith(stepIndex: 3);
      expect(updated.stepIndex, 3);
    });

    test('copyWith updates analysisComplete', () {
      const state = ChatState();
      final updated = state.copyWith(analysisComplete: true);
      expect(updated.analysisComplete, isTrue);
    });

    test('copyWith updates quotaExceeded', () {
      const state = ChatState();
      final updated = state.copyWith(quotaExceeded: true);
      expect(updated.quotaExceeded, isTrue);
    });
  });

  group('ChatMessage', () {
    test('creates with required fields', () {
      final msg = ChatMessage(role: 'user', content: 'hello');
      expect(msg.role, 'user');
      expect(msg.content, 'hello');
      expect(msg.isStreaming, isFalse);
    });

    test('isStreaming defaults to false', () {
      final msg = ChatMessage(role: 'assistant', content: 'hi');
      expect(msg.isStreaming, isFalse);
    });

    test('isStreaming can be set to true', () {
      final msg = ChatMessage(role: 'assistant', content: '', isStreaming: true);
      expect(msg.isStreaming, isTrue);
    });

    test('content is mutable', () {
      final msg = ChatMessage(role: 'assistant', content: '');
      msg.content = 'updated';
      expect(msg.content, 'updated');
    });
  });

  group('generateSessionId', () {
    test('returns valid UUID v4 format', () {
      final id = generateSessionId();
      final uuidV4Re = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        caseSensitive: false,
      );
      expect(uuidV4Re.hasMatch(id), isTrue);
    });

    test('generates unique IDs', () {
      final ids = List.generate(100, (_) => generateSessionId());
      expect(ids.toSet().length, 100);
    });

    test('is not empty', () {
      final id = generateSessionId();
      expect(id, isNotEmpty);
    });
  });

  group('kBodyAreaLabels', () {
    test('contains expected body areas', () {
      expect(kBodyAreaLabels.containsKey('neck'), isTrue);
      expect(kBodyAreaLabels.containsKey('lower_back'), isTrue);
      expect(kBodyAreaLabels.containsKey('left_knee'), isTrue);
    });

    test('labels are non-empty Turkish strings', () {
      for (final entry in kBodyAreaLabels.entries) {
        expect(entry.value, isNotEmpty, reason: '${entry.key} label is empty');
      }
    });
  });

  group('kQuickReplies', () {
    test('has expected number of steps', () {
      expect(kQuickReplies.length, 5);
    });

    test('each step has at least one reply', () {
      for (final step in kQuickReplies) {
        expect(step, isNotEmpty);
      }
    });
  });
}
