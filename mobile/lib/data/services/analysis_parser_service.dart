import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import '../models/analysis_model.dart';

/// Parses raw AI message text into structured data.
class AnalysisParserService {
  static const int _maxCauses = 5;
  /// Parses "YOUTUBE_EGZERSIZLER: egz1 | egz2 | egz3" from AI message.
  static List<String> parseExercises(String aiMessage) {
    final regex = RegExp(r'YOUTUBE_EGZERSIZLER:\s*(.+)', caseSensitive: false);
    final match = regex.firstMatch(aiMessage);
    if (match == null) {
      if (kDebugMode) debugPrint('[AnalysisParser] YOUTUBE_EGZERSIZLER etiketi bulunamadı — YouTube videosu gösterilmeyecek');
      return [];
    }
    return match
        .group(1)!
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Extracts the first 2–3 sentences as summary (strips YOUTUBE_EGZERSIZLER line).
  static String parseAiSummary(String aiMessage) {
    final cleaned = aiMessage
        .replaceAll(RegExp(r'YOUTUBE_EGZERSIZLER:.*', caseSensitive: false), '')
        .replaceAll(RegExp(r'\*\*|__'), '')
        .trim();
    final sentences = cleaned.split(RegExp(r'(?<=[.!?])\s+'));
    return sentences.take(3).join(' ').trim();
  }

  /// Extracts bullet-pointed lines as possible causes.
  static List<String> parsePossibleCauses(String aiMessage) {
    final lines = aiMessage.split('\n');
    final causes = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('•') ||
          trimmed.startsWith('-') ||
          trimmed.startsWith('*') ||
          RegExp(r'^\d+[.)]\s').hasMatch(trimmed)) {
        final cause = trimmed
            .replaceAll(RegExp(r'^[•\-*\d.)]+\s*'), '')
            .replaceAll(RegExp(r'\*\*|__'), '')
            .trim();
        if (cause.isNotEmpty && causes.length < _maxCauses) causes.add(cause);
      }
    }
    return causes;
  }

  /// Reads pain score from conversation history.
  static int parsePainScore(List<Map<String, String>> history) {
    for (final msg in history) {
      if (msg['role'] != 'user') continue;
      final c = msg['content'] ?? '';
      if (c.contains('1-3') || c.toLowerCase().contains('hafif')) return 2;
      if (c.contains('4-6') || c.toLowerCase().contains('orta')) return 5;
      if (c.contains('7-9') || c.toLowerCase().contains('şiddetli')) return 8;
      if (c.contains('10') || c.toLowerCase().contains('dayanılmaz')) return 10;
    }
    return 5;
  }

  /// Parses numbered exercise lines from AI message.
  /// Expected format: "1. [name] — [description] — [sets/reps]"
  static List<_ParsedExercise> _parseExerciseLines(String aiMessage) {
    final results = <_ParsedExercise>[];
    final lines = aiMessage.split('\n');
    final lineRe = RegExp(r'^\d+\.\s+(.+)');
    final youtubeRe = RegExp(r'YOUTUBE_EGZERSIZLER', caseSensitive: false);

    for (final line in lines) {
      if (youtubeRe.hasMatch(line)) continue; // bu satırı egzersiz olarak parse etme
      final m = lineRe.firstMatch(line.trim());
      if (m == null) continue;
      final parts = m.group(1)!.split(RegExp(r'\s*—\s*|\s*-{2,}\s*'));
      if (parts.isEmpty) continue;

      final name = parts[0].trim();
      final description = parts.length > 1 ? parts[1].trim() : '';
      final durationRaw = parts.length > 2 ? parts[2].trim() : '';

      // Infer difficulty from keywords in description + name
      final combined = '$name $description'.toLowerCase();
      final String difficulty;
      if (combined.contains('ileri') ||
          combined.contains('zor') ||
          combined.contains('plank') ||
          combined.contains('dead bug') ||
          combined.contains('bird dog')) {
        difficulty = 'Zor';
      } else if (combined.contains('nazik') ||
          combined.contains('hafif') ||
          combined.contains('germe') ||
          combined.contains('stretch')) {
        difficulty = 'Kolay';
      } else {
        difficulty = 'Orta';
      }

      results.add(
        _ParsedExercise(
          name: name,
          description: description,
          difficulty: difficulty,
          duration: durationRaw.isNotEmpty ? durationRaw : '3 set x 10 tekrar',
        ),
      );
    }
    return results;
  }

  /// Builds a complete AnalysisModel from the finished conversation.
  static AnalysisModel buildAnalysisModel({
    required String lastAiMsg,
    required List<String> exerciseNames,
    required String bodyArea,
    required String bodyAreaLabel,
    required List<Map<String, String>> history,
  }) {
    final causes = parsePossibleCauses(lastAiMsg);
    final summary = parseAiSummary(lastAiMsg);
    final painScore = parsePainScore(history);
    final parsedLines = _parseExerciseLines(lastAiMsg);

    // Match parsed lines to exerciseNames; fall back to name-only if not found
    final exercises = exerciseNames.map((name) {
      final found = parsedLines
          .where(
            (p) =>
                p.name.toLowerCase().contains(name.toLowerCase()) ||
                name.toLowerCase().contains(p.name.toLowerCase()),
          )
          .firstOrNull;
      return ExerciseModel(
        name: name,
        description: found?.description ?? '',
        difficulty: found?.difficulty ?? 'Orta',
        duration: found?.duration ?? '3 set x 10 tekrar',
      );
    }).toList();

    return AnalysisModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bodyArea: bodyArea,
      bodyAreaLabel: bodyAreaLabel,
      painScore: painScore,
      userComplaint: history
          .where((m) => m['role'] == 'user')
          .map((m) => m['content'] ?? '')
          .join(' | '),
      aiSummary: summary.isNotEmpty
          ? summary
          : '$bodyAreaLabel bölgesinde ağrı analizi tamamlandı.',
      possibleCauses: causes.isNotEmpty
          ? causes
          : ['Kas gerilmesi', 'Postür bozukluğu', 'Aşırı kullanım'],
      exercises: exercises,
      videos: [],
      createdAt: DateTime.now(),
    );
  }
}

class _ParsedExercise {
  final String name;
  final String description;
  final String difficulty;
  final String duration;

  const _ParsedExercise({
    required this.name,
    required this.description,
    required this.difficulty,
    required this.duration,
  });
}
