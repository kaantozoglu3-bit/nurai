import 'package:flutter_test/flutter_test.dart';
import 'package:painrelief_ai/data/services/analysis_parser_service.dart';

void main() {
  // ─── parseExercises ─────────────────────────────────────────────────────────

  group('parseExercises', () {
    test('parses pipe-separated exercises from YOUTUBE_EGZERSIZLER line', () {
      const msg =
          'Some analysis text.\nYOUTUBE_EGZERSIZLER: Pelvik tilt | Bird dog | Glute bridge';
      final result = AnalysisParserService.parseExercises(msg);
      expect(result, ['Pelvik tilt', 'Bird dog', 'Glute bridge']);
    });

    test('is case-insensitive for YOUTUBE_EGZERSIZLER label', () {
      const msg = 'youtube_egzersizler: Chin tuck | Skapular retraksiyon';
      final result = AnalysisParserService.parseExercises(msg);
      expect(result, ['Chin tuck', 'Skapular retraksiyon']);
    });

    test('trims whitespace around exercise names', () {
      const msg = 'YOUTUBE_EGZERSIZLER:   Dead bug  |  Plank  ';
      final result = AnalysisParserService.parseExercises(msg);
      expect(result, ['Dead bug', 'Plank']);
    });

    test('returns empty list when YOUTUBE_EGZERSIZLER tag is absent', () {
      const msg = 'No exercises mentioned here.';
      final result = AnalysisParserService.parseExercises(msg);
      expect(result, isEmpty);
    });

    test('filters out empty segments from extra pipes', () {
      const msg = 'YOUTUBE_EGZERSIZLER: Quad sets | | McKenzie';
      final result = AnalysisParserService.parseExercises(msg);
      expect(result, ['Quad sets', 'McKenzie']);
    });

    test('handles single exercise without pipe', () {
      const msg = 'YOUTUBE_EGZERSIZLER: Boyun izometrik';
      final result = AnalysisParserService.parseExercises(msg);
      expect(result, ['Boyun izometrik']);
    });
  });

  // ─── parseAiSummary ─────────────────────────────────────────────────────────

  group('parseAiSummary', () {
    test('removes YOUTUBE_EGZERSIZLER line from summary', () {
      const msg =
          'Değerlendirme: Kas gerilmesi mevcut. İyi haber ağrı geçici.\nYOUTUBE_EGZERSIZLER: Pelvik tilt';
      final result = AnalysisParserService.parseAiSummary(msg);
      expect(result, isNot(contains('YOUTUBE_EGZERSIZLER')));
    });

    test('strips bold markdown markers', () {
      const msg = '**Değerlendirme:** Ağrı kronik görünüyor.';
      final result = AnalysisParserService.parseAiSummary(msg);
      expect(result, isNot(contains('**')));
    });

    test('returns at most 3 sentences', () {
      const msg =
          'Birinci cümle. İkinci cümle. Üçüncü cümle. Dördüncü cümle. Beşinci cümle.';
      final result = AnalysisParserService.parseAiSummary(msg);
      // Count sentence-ending punctuation
      final dots = '.'.allMatches(result).length;
      expect(dots, lessThanOrEqualTo(3));
    });

    test('trims result', () {
      const msg = '  Ağrı analizi tamamlandı.  ';
      final result = AnalysisParserService.parseAiSummary(msg);
      expect(result, 'Ağrı analizi tamamlandı.');
    });

    test('handles empty string gracefully', () {
      final result = AnalysisParserService.parseAiSummary('');
      expect(result, isEmpty);
    });
  });

  // ─── parsePossibleCauses ────────────────────────────────────────────────────

  group('parsePossibleCauses', () {
    test('extracts bullet-point lines starting with •', () {
      const msg = '• Kas gerilmesi\n• Postür bozukluğu\n• Aşırı kullanım';
      final result = AnalysisParserService.parsePossibleCauses(msg);
      expect(result, contains('Kas gerilmesi'));
      expect(result, contains('Postür bozukluğu'));
      expect(result, contains('Aşırı kullanım'));
    });

    test('extracts numbered list items', () {
      const msg = '1. Disk hernisi\n2. Faset eklem irritasyonu';
      final result = AnalysisParserService.parsePossibleCauses(msg);
      expect(result, contains('Disk hernisi'));
      expect(result, contains('Faset eklem irritasyonu'));
    });

    test('extracts dash-prefixed lines', () {
      const msg = '- Tendon irritasyonu\n- Bursit';
      final result = AnalysisParserService.parsePossibleCauses(msg);
      expect(result, contains('Tendon irritasyonu'));
      expect(result, contains('Bursit'));
    });

    test('strips bold markdown from causes', () {
      const msg = '• **Kas gerilmesi**';
      final result = AnalysisParserService.parsePossibleCauses(msg);
      expect(result.first, 'Kas gerilmesi');
    });

    test('limits to 5 causes maximum', () {
      final lines = List.generate(
        10,
        (i) => '• Neden ${i + 1}',
      ).join('\n');
      final result = AnalysisParserService.parsePossibleCauses(lines);
      expect(result.length, lessThanOrEqualTo(5));
    });

    test('returns empty list when no bullet lines present', () {
      const msg = 'Normal bir paragraf metni, liste yok.';
      final result = AnalysisParserService.parsePossibleCauses(msg);
      expect(result, isEmpty);
    });
  });

  // ─── parsePainScore ─────────────────────────────────────────────────────────

  group('parsePainScore', () {
    test('returns 2 for mild pain keywords', () {
      final history = [
        {'role': 'user', 'content': 'Ağrım hafif seviyede'},
      ];
      expect(AnalysisParserService.parsePainScore(history), 2);
    });

    test('returns 5 for moderate pain keywords', () {
      final history = [
        {'role': 'user', 'content': 'Orta şiddetli ağrı var'},
      ];
      expect(AnalysisParserService.parsePainScore(history), 5);
    });

    test('returns 8 for severe pain keywords', () {
      final history = [
        {'role': 'user', 'content': 'Şiddetli ağrı çekiyorum'},
      ];
      expect(AnalysisParserService.parsePainScore(history), 8);
    });

    test('returns 10 for unbearable pain keywords', () {
      final history = [
        {'role': 'user', 'content': 'Dayanılmaz bir ağrı'},
      ];
      expect(AnalysisParserService.parsePainScore(history), 10);
    });

    test('defaults to 5 when no pain keywords found', () {
      final history = [
        {'role': 'user', 'content': 'Bilmiyorum nasıl anlatayım'},
      ];
      expect(AnalysisParserService.parsePainScore(history), 5);
    });

    test('ignores assistant messages', () {
      final history = [
        {'role': 'assistant', 'content': 'Dayanılmaz ağrı yaşıyor musunuz?'},
        {'role': 'user', 'content': 'Hafif bir rahatsızlık var'},
      ];
      expect(AnalysisParserService.parsePainScore(history), 2);
    });

    test('returns 5 for empty history', () {
      expect(AnalysisParserService.parsePainScore([]), 5);
    });
  });

  // ─── buildAnalysisModel ─────────────────────────────────────────────────────

  group('buildAnalysisModel', () {
    const sampleAiMsg = '''
**Değerlendirme:** Kronik bel ağrısı mevcut. Postür bozukluğu olası neden.
**Güven:** En olası: kas gerilmesi.

**Egzersiz Programı:**
1. Bird dog — Sırt düz, karşı kol-bacak uzat — 3 set x 10 tekrar
2. Glute bridge — Sırt üstü yat, kalçayı kaldır — 3 set x 15 tekrar
3. Pelvik tilt — Sırt üstü yat, beli yere bas — 3 set x 12 tekrar

• Kas gerilmesi
• Postür bozukluğu

YOUTUBE_EGZERSIZLER: Bird dog | Glute bridge | Pelvik tilt
''';

    final sampleHistory = [
      {'role': 'user', 'content': 'Belim ağrıyor, orta şiddetli'},
      {'role': 'assistant', 'content': 'Ne zamandır devam ediyor?'},
      {'role': 'user', 'content': '2 haftadır'},
    ];

    test('builds model with correct body area fields', () {
      final model = AnalysisParserService.buildAnalysisModel(
        lastAiMsg: sampleAiMsg,
        exerciseNames: ['Bird dog', 'Glute bridge', 'Pelvik tilt'],
        bodyArea: 'lower_back',
        bodyAreaLabel: 'Alt Sırt',
        history: sampleHistory,
      );
      expect(model.bodyArea, 'lower_back');
      expect(model.bodyAreaLabel, 'Alt Sırt');
    });

    test('populates exercises list from exerciseNames', () {
      final model = AnalysisParserService.buildAnalysisModel(
        lastAiMsg: sampleAiMsg,
        exerciseNames: ['Bird dog', 'Glute bridge'],
        bodyArea: 'lower_back',
        bodyAreaLabel: 'Alt Sırt',
        history: sampleHistory,
      );
      expect(model.exercises.length, 2);
      expect(model.exercises.map((e) => e.name), contains('Bird dog'));
      expect(model.exercises.map((e) => e.name), contains('Glute bridge'));
    });

    test('exercise description is filled from parsed numbered lines', () {
      final model = AnalysisParserService.buildAnalysisModel(
        lastAiMsg: sampleAiMsg,
        exerciseNames: ['Bird dog'],
        bodyArea: 'lower_back',
        bodyAreaLabel: 'Alt Sırt',
        history: sampleHistory,
      );
      final exercise = model.exercises.first;
      expect(exercise.description, isNotEmpty);
    });

    test('populates possible causes from bullet lines', () {
      final model = AnalysisParserService.buildAnalysisModel(
        lastAiMsg: sampleAiMsg,
        exerciseNames: ['Bird dog'],
        bodyArea: 'lower_back',
        bodyAreaLabel: 'Alt Sırt',
        history: sampleHistory,
      );
      expect(model.possibleCauses, isNotEmpty);
    });

    test('falls back to default causes when none found in message', () {
      final model = AnalysisParserService.buildAnalysisModel(
        lastAiMsg: 'Herhangi bir liste yok burada.',
        exerciseNames: ['Bird dog'],
        bodyArea: 'lower_back',
        bodyAreaLabel: 'Alt Sırt',
        history: sampleHistory,
      );
      expect(model.possibleCauses, isNotEmpty);
    });

    test('aiSummary falls back to label when message is empty', () {
      final model = AnalysisParserService.buildAnalysisModel(
        lastAiMsg: '',
        exerciseNames: [],
        bodyArea: 'lower_back',
        bodyAreaLabel: 'Alt Sırt',
        history: [],
      );
      expect(model.aiSummary, contains('Alt Sırt'));
    });

    test('userComplaint joins user messages with separator', () {
      final model = AnalysisParserService.buildAnalysisModel(
        lastAiMsg: sampleAiMsg,
        exerciseNames: [],
        bodyArea: 'lower_back',
        bodyAreaLabel: 'Alt Sırt',
        history: sampleHistory,
      );
      expect(model.userComplaint, contains('Belim ağrıyor'));
      expect(model.userComplaint, contains('2 haftadır'));
    });

    test('model id is non-empty string', () {
      final model = AnalysisParserService.buildAnalysisModel(
        lastAiMsg: sampleAiMsg,
        exerciseNames: ['Bird dog'],
        bodyArea: 'lower_back',
        bodyAreaLabel: 'Alt Sırt',
        history: sampleHistory,
      );
      expect(model.id, isNotEmpty);
    });

    test('handles extra unknown fields in AI message gracefully', () {
      const msgWithExtra = '''
UNKNOWN_FIELD: some value
ANOTHER_TAG: ignored

1. Plank — Düz tut — 3x30sn
YOUTUBE_EGZERSIZLER: Plank
''';
      expect(
        () => AnalysisParserService.buildAnalysisModel(
          lastAiMsg: msgWithExtra,
          exerciseNames: ['Plank'],
          bodyArea: 'core',
          bodyAreaLabel: 'Core',
          history: [],
        ),
        returnsNormally,
      );
    });
  });
}
