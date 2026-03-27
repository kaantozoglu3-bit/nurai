import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import '../models/analysis_model.dart';

/// Parses raw AI message text into structured data.
class AnalysisParserService {
  static const int _maxCauses = 5;
  /// Parses "VIDEO_IDS: egz1 | egz2 | egz3" (or comma-separated) from AI message.
  static List<String> parseExercises(String aiMessage) {
    final regex = RegExp(r'VIDEO_IDS:\s*(.+)', caseSensitive: false);
    final match = regex.firstMatch(aiMessage);
    if (match == null) {
      if (kDebugMode) debugPrint('[AnalysisParser] VIDEO_IDS etiketi bulunamadı — Lokal video gösterilmeyecek');
      return [];
    }
    final raw = match.group(1)!;
    // Support both pipe (|) and comma (,) as delimiters — LLMs may use either.
    final delimiter = raw.contains('|') ? '|' : ',';
    return raw
        .split(delimiter)
        .map((e) => e
            .replaceAll(RegExp(r'^\[|\]$'), '') // strip surrounding brackets
            .trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Extracts the first 2–3 sentences as summary (strips VIDEO_IDS line).
  static String parseAiSummary(String aiMessage) {
    final cleaned = aiMessage
        .replaceAll(RegExp(r'VIDEO_IDS:.*', caseSensitive: false), '')
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
  /// Expected format: "1. [name] — [description] — [sets/reps]" or "1. [name] — [description] — [sets/reps] — [video_id]"
  static List<_ParsedExercise> _parseExerciseLines(String aiMessage) {
    final results = <_ParsedExercise>[];
    final lines = aiMessage.split('\n');
    final lineRe = RegExp(r'^\d+\.\s+(.+)');
    final youtubeRe = RegExp(r'VIDEO_IDS|Rehabilitasyon Programı|Egzersiz Programı', caseSensitive: false);

    for (final line in lines) {
      if (youtubeRe.hasMatch(line)) continue; // skip header lines
      final m = lineRe.firstMatch(line.trim());
      if (m == null) continue;
      
      final fullContent = m.group(1)!;
      final parts = fullContent.split(RegExp(r'\s*—\s*|\s*-{2,}\s*'));
      if (parts.isEmpty || parts[0].trim().isEmpty) continue;

      final name = parts[0].trim();
      final description = parts.length > 1 ? parts[1].trim() : '';
      final durationRaw = parts.length > 2 ? parts[2].trim() : '';
      final videoIdRaw = parts.length > 3 ? parts[3].trim() : '';

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
          videoId: videoIdRaw.isNotEmpty ? videoIdRaw : '',
        ),
      );

      if (kDebugMode) {
        debugPrint('[AnalysisParser] Egzersiz parsed: name="$name", parts=${parts.length}, duration="$durationRaw"');
      }
    }

    if (kDebugMode) {
      debugPrint('[AnalysisParser] Total exercises found: ${results.length}');
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

    // Simply convert parsed lines to ExerciseModels
    final exercises = parsedLines.map((p) {
      return ExerciseModel(
        name: p.name,
        description: p.description,
        difficulty: p.difficulty,
        duration: p.duration,
        videoId: p.videoId.isNotEmpty ? p.videoId : null,
      );
    }).toList();

    if (kDebugMode) {
      debugPrint('[AnalysisParser] buildAnalysisModel: exercises.length=${exercises.length}, causes.length=${causes.length}');
    }

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
  final String videoId;

  const _ParsedExercise({
    required this.name,
    required this.description,
    required this.difficulty,
    required this.duration,
    required this.videoId,
  });
}
