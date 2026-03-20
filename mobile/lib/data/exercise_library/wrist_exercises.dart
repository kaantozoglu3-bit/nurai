import '../models/exercise_library_model.dart';

const BodyAreaLibrary leftWristExercises = BodyAreaLibrary(
  key: 'left_wrist',
  label: 'Sol Bilek',
  exercises: _wristExercises,
);

const BodyAreaLibrary rightWristExercises = BodyAreaLibrary(
  key: 'right_wrist',
  label: 'Sağ Bilek',
  exercises: _wristExercises,
);

const List<ExerciseLibraryItem> _wristExercises = [
  ExerciseLibraryItem(
    name: 'Bilek Fleksiyon Germe',
    description:
        'Kolunuzu uzatın, elinizi aşağı bastırın ve tutun. Bilek fleksörlerini esnetir.',
    sets: '3 x 30 saniye',
    difficulty: 'Kolay',
    phase: 'Akut',
    youtubeSearchTerm: 'wrist stretch exercise',
    rehabPhase: 'acute',
    category: 'stretch',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Bilek Ekstansiyon Germe',
    description:
        'Elinizi yukarı doğru gerin ve tutun. Bilek ekstansörlerini esnetir.',
    sets: '3 x 30 saniye',
    difficulty: 'Kolay',
    phase: 'Akut',
    youtubeSearchTerm: 'wrist flexor stretch elbow',
    rehabPhase: 'acute',
    category: 'stretch',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Tendon Kaydırma',
    description:
        'Parmaklarla farklı pozisyonlarda kaydırma hareketleri yapılır. Tendon sürtünmesini azaltır.',
    sets: '3 set x 10 tekrar',
    difficulty: 'Orta',
    phase: 'Kronik',
    youtubeSearchTerm: 'tendon gliding exercises hand',
    rehabPhase: 'subacute',
    category: 'mobility',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: ['Akut tendon yırtığı'],
  ),
  ExerciseLibraryItem(
    name: 'Kavrama Güçlendirme',
    description:
        'Stres topu sıkıştırılır ve bırakılır. Bilek ve el kaslarını güçlendirir.',
    sets: '3 set x 20 tekrar',
    difficulty: 'Orta',
    phase: 'Kronik',
    youtubeSearchTerm: 'grip strengthening exercise',
    rehabPhase: 'subacute',
    category: 'strength',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  // Yeni eklenen egzersizler
  ExerciseLibraryItem(
    name: 'Stres Topu Sıkma',
    description:
        'Stres topunu elinizde sıkıştırın ve bırakın. El ve bilek kaslarını aktive eder.',
    sets: '3 set x 15 tekrar',
    difficulty: 'Kolay',
    phase: 'Akut',
    youtubeSearchTerm: 'stress ball squeeze exercise',
    rehabPhase: 'acute',
    category: 'strength',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Bilek Güçlendirme',
    description:
        'Önkolunuzu masaya dayayıp bileği yukarı-aşağı hareket ettirin. Bilek kaslarını dengeli güçlendirir.',
    sets: '3 set x 15 tekrar',
    difficulty: 'Orta',
    phase: 'Kronik',
    youtubeSearchTerm: 'wrist strengthening exercises',
    rehabPhase: 'subacute',
    category: 'strength',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Pronasyon Supinasyon',
    description:
        'Önkolunuzu masaya dayayıp avuç içini yukarı-aşağı döndürün. Bilek rotasyon kaslarını çalıştırır.',
    sets: '3 set x 15 tekrar',
    difficulty: 'Kolay',
    phase: 'Kronik',
    youtubeSearchTerm: 'wrist pronation supination exercise',
    rehabPhase: 'subacute',
    category: 'mobility',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Median Sinir Kaydırma',
    description:
        'Kolu uzatıp bileği geriye katlayın, boynu karşı yana eğin. Karpal tünel sendromunda sinir kaydırmasını sağlar.',
    sets: '3 set x 10 tekrar',
    difficulty: 'Orta',
    phase: 'Rehabilitasyon',
    youtubeSearchTerm: 'median nerve gliding carpal tunnel',
    rehabPhase: 'rebuilding',
    category: 'mobility',
    painRule: 'Elektrik çakması hissedilirse hemen dur',
    contraindications: ['Akut karpal tünel sendromu şiddetli'],
  ),
  ExerciseLibraryItem(
    name: 'Bilek Çevirmesi',
    description:
        'Bileğinizi yavaşça tam daire çizecek şekilde çevirin. Eklem hareketliliğini artırır.',
    sets: '2 set x 15 tekrar',
    difficulty: 'Kolay',
    phase: 'Kronik',
    youtubeSearchTerm: 'wrist circle ROM exercise',
    rehabPhase: 'subacute',
    category: 'mobility',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Radial Deviasyon',
    description:
        'Önkolunuzu masaya dayayın ve bileği başparmak yönüne kaydırın. Bilek radial taraf kaslarını güçlendirir.',
    sets: '3 set x 15 tekrar',
    difficulty: 'Orta',
    phase: 'Rehabilitasyon',
    youtubeSearchTerm: 'wrist radial deviation exercise',
    rehabPhase: 'rebuilding',
    category: 'strength',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Ulnar Deviasyon',
    description:
        'Önkolunuzu masaya dayayın ve bileği serçe parmak yönüne kaydırın. Bilek ulnar taraf kaslarını güçlendirir.',
    sets: '3 set x 15 tekrar',
    difficulty: 'Orta',
    phase: 'Rehabilitasyon',
    youtubeSearchTerm: 'wrist ulnar deviation exercise',
    rehabPhase: 'rebuilding',
    category: 'strength',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Parmak Abdüksiyonu',
    description:
        'Parmaklarınızı açıp kapatın. El kas koordinasyonunu ve güçlendirmesini sağlar.',
    sets: '3 set x 15 tekrar',
    difficulty: 'Kolay',
    phase: 'Kronik',
    youtubeSearchTerm: 'finger abduction adduction exercise',
    rehabPhase: 'subacute',
    category: 'strength',
    painRule: 'Ağrı artarsa dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Dua Pozisyonu Germe',
    description:
        'Avuçları birleştirip bileği aşağıya indirin ve tutun. Bilek fleksörlerini dengeli esnetir.',
    sets: '3 x 30 saniye',
    difficulty: 'Kolay',
    phase: 'Kronik',
    youtubeSearchTerm: 'prayer stretch wrist flexion',
    rehabPhase: 'subacute',
    category: 'stretch',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
];
