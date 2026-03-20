import '../models/exercise_library_model.dart';

const BodyAreaLibrary leftShoulderExercises = BodyAreaLibrary(
  key: 'left_shoulder',
  label: 'Sol Omuz',
  exercises: _shoulderExercises,
);

const BodyAreaLibrary rightShoulderExercises = BodyAreaLibrary(
  key: 'right_shoulder',
  label: 'Sağ Omuz',
  exercises: _shoulderExercises,
);

const List<ExerciseLibraryItem> _shoulderExercises = [
  ExerciseLibraryItem(
    name: 'Sarkaç Egzersizi (Codman)',
    description:
        'Öne eğilip kolu serbest sallayın. Omuz eklemini mobilize eder, ağrıyı azaltır.',
    sets: '2 set x 30 saniye',
    difficulty: 'Kolay',
    phase: 'Akut',
    youtubeSearchTerm: 'Codman pendulum shoulder exercise',
    rehabPhase: 'acute',
    category: 'mobility',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: ['Omuz dislokasyonu'],
  ),
  ExerciseLibraryItem(
    name: 'Nazik İç/Dış Rotasyon',
    description:
        'Dirseği 90° büküp kolu içe-dışa döndürün. Rotator cuff eklemini ısıtır.',
    sets: '2 set x 10 tekrar (her yön)',
    difficulty: 'Kolay',
    phase: 'Akut',
    youtubeSearchTerm: 'isometric shoulder external rotation',
    rehabPhase: 'acute',
    category: 'activation',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: ['Akut rotator cuff yırtığı'],
  ),
  ExerciseLibraryItem(
    name: 'Kürek Kemiği Sıkıştırma',
    description:
        'Omuzları geriye çekip kürek kemiklerini birleştirin. Postür kaslarını aktive eder.',
    sets: '3 set x 12 tekrar',
    difficulty: 'Kolay',
    phase: 'Akut',
    youtubeSearchTerm: 'scapular squeeze exercise',
    rehabPhase: 'acute',
    category: 'activation',
    painRule: 'Ağrı artarsa dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Omuz Kapsül Germe (Sleeper Stretch)',
    description:
        'Yana yatıp kolun önkolu yere doğru bastırılır. Arka kapsülü esnetir.',
    sets: '3 x 30 saniye',
    difficulty: 'Orta',
    phase: 'Kronik',
    youtubeSearchTerm: 'sleeper stretch shoulder',
    rehabPhase: 'subacute',
    category: 'stretch',
    painRule: 'Ağrı 5/10 üzerindeyse dur',
    contraindications: ['Akut omuz ağrısı'],
  ),
  ExerciseLibraryItem(
    name: 'Dış Rotasyon Güçlendirme',
    description:
        'Dirsek yana, önkol dışa döndürülür (theraband ile). Rotator cuff\'ı güçlendirir.',
    sets: '3 set x 15 tekrar',
    difficulty: 'Orta',
    phase: 'Kronik',
    youtubeSearchTerm: 'shoulder external rotation band exercise',
    rehabPhase: 'subacute',
    category: 'strength',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: ['Akut rotator cuff yırtığı'],
  ),
  ExerciseLibraryItem(
    name: 'Prone Y-T-W Egzersizi',
    description:
        'Yüzüstü kolları Y, T, W şeklinde kaldırın. Skapular stabilizasyonu güçlendirir.',
    sets: '3 set x 10 tekrar (her pozisyon)',
    difficulty: 'Zor',
    phase: 'Kronik',
    youtubeSearchTerm: 'prone YTW shoulder exercise',
    rehabPhase: 'rebuilding',
    category: 'strength',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: ['Akut omuz lezyonu'],
  ),
  // Yeni eklenen egzersizler
  ExerciseLibraryItem(
    name: 'İzometrik Dış Rotasyon',
    description:
        'Dirseği 90° büküp duvara dayayın ve dışa döndürmeye çalışın, 5 saniye tutun. Omuz eklemini yüklenmeden çalıştırır.',
    sets: '3 set x 10 tekrar (5 sn tutma)',
    difficulty: 'Kolay',
    phase: 'Akut',
    youtubeSearchTerm: 'isometric shoulder external rotation',
    rehabPhase: 'acute',
    category: 'activation',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: ['Akut rotator cuff yırtığı'],
  ),
  ExerciseLibraryItem(
    name: 'Duvar Push-Up',
    description:
        'Duvara dönük ayakta durup elleri duvara basın ve dirsekleri büküp açın. Omuz kaslarını yavaş yavaş güçlendirir.',
    sets: '3 set x 15 tekrar',
    difficulty: 'Kolay',
    phase: 'Kronik',
    youtubeSearchTerm: 'wall push up shoulder rehab',
    rehabPhase: 'subacute',
    category: 'strength',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Aktif Yardımlı Fleksiyon',
    description:
        'Sağlıklı elinizle hasta kolu destekleyerek yavaşça kaldırın. Omuz hareketliliğini güvenli artırır.',
    sets: '3 set x 10 tekrar',
    difficulty: 'Kolay',
    phase: 'Rehabilitasyon',
    youtubeSearchTerm: 'active assisted shoulder flexion',
    rehabPhase: 'rebuilding',
    category: 'mobility',
    painRule: 'Ağrı 5/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Scapular Clock',
    description:
        'Skapülayı saat ibresi gibi döndürün, her pozisyonda 2 saniye tutun. Omuz stabilitesini geliştirir.',
    sets: '3 set x 10 tekrar',
    difficulty: 'Orta',
    phase: 'Rehabilitasyon',
    youtubeSearchTerm: 'scapular clock exercise',
    rehabPhase: 'rebuilding',
    category: 'stability',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Crossover Arm Germe',
    description:
        'Kolu göğsün önünden karşıya uzatın ve diğer elinizle hafifçe bastırın. Arka omuz kapsülünü esnetir.',
    sets: '3 x 30 saniye (her taraf)',
    difficulty: 'Kolay',
    phase: 'Kronik',
    youtubeSearchTerm: 'crossover arm stretch shoulder',
    rehabPhase: 'subacute',
    category: 'stretch',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Wall Slides',
    description:
        'Duvara sırtı dayayıp kolları duvarda yukarı kaydırın. Omuz hareketliliğini ve postürü iyileştirir.',
    sets: '3 set x 15 tekrar',
    difficulty: 'Kolay',
    phase: 'Kronik',
    youtubeSearchTerm: 'wall slide shoulder exercise',
    rehabPhase: 'subacute',
    category: 'mobility',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'İç Rotasyon Bant ile',
    description:
        'Theraband ile dirseği yana tutup önkolu içe döndürün. Subscapularis kasını güçlendirir.',
    sets: '3 set x 15 tekrar',
    difficulty: 'Orta',
    phase: 'Rehabilitasyon',
    youtubeSearchTerm: 'resistance band internal rotation shoulder',
    rehabPhase: 'rebuilding',
    category: 'strength',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: ['Akut rotator cuff yırtığı'],
  ),
  ExerciseLibraryItem(
    name: 'Serratus Wall Punch',
    description:
        'Duvara dönük elinizi duvara bastırıp kürek kemiğini öne ittiğinizde tutun. Serratus anterior kasını güçlendirir.',
    sets: '3 set x 15 tekrar',
    difficulty: 'Orta',
    phase: 'Rehabilitasyon',
    youtubeSearchTerm: 'serratus anterior wall punch',
    rehabPhase: 'rebuilding',
    category: 'strength',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
];
