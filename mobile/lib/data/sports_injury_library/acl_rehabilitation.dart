// ACL (Ön Çapraz Bağ) Rehabilitasyon Protokolü
class AclRehabPhase {
  final int phase;
  final String name;
  final String duration;
  final List<String> goals;
  final List<RehabExercise> exercises;

  const AclRehabPhase({
    required this.phase,
    required this.name,
    required this.duration,
    required this.goals,
    required this.exercises,
  });
}

class RehabExercise {
  final String name;
  final String description;
  final String setsReps;
  final String? videoId;

  const RehabExercise({
    required this.name,
    required this.description,
    required this.setsReps,
    this.videoId,
  });
}

class AclRehabilitation {
  static const String injuryName = 'ACL (Ön Çapraz Bağ) Hasarı';
  static const String injuryDescription =
      'Ön çapraz bağ yırtığı veya hasarı rehabilitasyonu. '
      'Cerrahi veya konservatif tedavi sonrası 5 fazlı program.';

  static const List<AclRehabPhase> phases = [
    AclRehabPhase(
      phase: 1,
      name: 'Akut Faz — Ağrı ve Ödem Kontrolü',
      duration: '0-2. Hafta',
      goals: [
        'Ağrıyı azalt',
        'Ödemi kontrol et',
        'Quad aktivasyonu sağla',
        'Tam ekstansiyona ulaş'
      ],
      exercises: [
        RehabExercise(
          name: 'Quad Set',
          description: 'Diz düz pozisyonda quad kasılması, 5 sn tut',
          setsReps: '3x15',
        ),
        RehabExercise(
          name: 'Topuk Kaydırma (AROM)',
          description: 'Sırtüstü yatarak topuğu yavaşça kaydır',
          setsReps: '3x10',
        ),
        RehabExercise(
          name: 'Düz Bacak Kaldırma',
          description: 'Diz düz, bacağı 45° kaldır ve tut',
          setsReps: '3x15',
        ),
        RehabExercise(
          name: 'Buz Uygulaması',
          description: 'Her 2 saatte 15-20 dk',
          setsReps: '4-6x/gün',
        ),
      ],
    ),
    AclRehabPhase(
      phase: 2,
      name: 'Güç Kazanımı Fazı',
      duration: '2-6. Hafta',
      goals: ['ROM artır', 'Kas gücünü kazan', 'Yük vermeye başla'],
      exercises: [
        RehabExercise(
          name: 'Mini Squat (0-60°)',
          description: 'Duvardan destek alarak yarım squat',
          setsReps: '3x15',
        ),
        RehabExercise(
          name: 'Leg Press',
          description: '0-60° açıda hafif yük ile',
          setsReps: '3x12',
        ),
        RehabExercise(
          name: 'Hamstring Curl',
          description: 'Prone pozisyonda diz bükme',
          setsReps: '3x12',
        ),
        RehabExercise(
          name: 'Calf Raise',
          description: 'Ayakta topuk kaldırma',
          setsReps: '3x20',
        ),
        RehabExercise(
          name: 'Bisiklet (Sabit)',
          description: 'Düşük dirençle 20 dk',
          setsReps: '1x20 dk',
        ),
      ],
    ),
    AclRehabPhase(
      phase: 3,
      name: 'Fonksiyonel Güç Fazı',
      duration: '6-12. Hafta',
      goals: [
        'Kas gücünü normalize et',
        'Denge geliştir',
        'Spor hareketlerine hazırla'
      ],
      exercises: [
        RehabExercise(
          name: 'Tek Bacak Squat',
          description: 'Kontrollü iniş-kalkış',
          setsReps: '3x10',
        ),
        RehabExercise(
          name: 'Step Up/Down',
          description: '20-30 cm yüksekliğe çıkış-iniş',
          setsReps: '3x12',
        ),
        RehabExercise(
          name: 'Lateral Band Walk',
          description: 'Direnç bandıyla yanlara yürüyüş',
          setsReps: '3x15',
        ),
        RehabExercise(
          name: 'Denge Tahtası',
          description: 'Tek bacak denge 30-60 sn',
          setsReps: '3x45 sn',
        ),
        RehabExercise(
          name: 'Nordic Hamstring',
          description: 'Diz bükülerek öne eğilme',
          setsReps: '3x6',
        ),
      ],
    ),
    AclRehabPhase(
      phase: 4,
      name: 'Koşu ve Çeviklik Fazı',
      duration: '3-6. Ay',
      goals: [
        'Koşuya başla',
        'Yön değiştirme hareketleri',
        'Sport-specific antrenman'
      ],
      exercises: [
        RehabExercise(
          name: 'Jogging (Düz)',
          description: 'Düz zeminde hafif koşu',
          setsReps: '20-30 dk',
        ),
        RehabExercise(
          name: 'Lateral Shuffle',
          description: 'Yanlara süratli kayma',
          setsReps: '4x15 m',
        ),
        RehabExercise(
          name: 'Kerioca',
          description: 'Çapraz adım koşusu',
          setsReps: '4x20 m',
        ),
        RehabExercise(
          name: 'Box Jump (Düşük)',
          description: '20 cm kutuya iki ayak atlayış',
          setsReps: '3x8',
        ),
      ],
    ),
    AclRehabPhase(
      phase: 5,
      name: 'Spora Dönüş Fazı',
      duration: '6-9. Ay',
      goals: [
        'Spora tam dönüş',
        'Yeniden yaralanmayı önle',
        'Güven yeniden kazanımı'
      ],
      exercises: [
        RehabExercise(
          name: 'Sprint Protokolü',
          description: '%60→%80→%100 hız progresyonu',
          setsReps: '6x40 m',
        ),
        RehabExercise(
          name: 'Spor-Spesifik Driller',
          description: 'Branşa özgü hareketler',
          setsReps: '3x seri',
        ),
        RehabExercise(
          name: 'Pivot/Kesme Hareketleri',
          description: 'Kontrollü yön değiştirme',
          setsReps: '3x10',
        ),
      ],
    ),
  ];
}
