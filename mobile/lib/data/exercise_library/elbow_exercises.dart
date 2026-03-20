import '../models/exercise_library_model.dart';

const BodyAreaLibrary leftElbowExercises = BodyAreaLibrary(
  key: 'left_elbow',
  label: 'Sol Dirsek',
  exercises: _elbowExercises,
);

const BodyAreaLibrary rightElbowExercises = BodyAreaLibrary(
  key: 'right_elbow',
  label: 'Sağ Dirsek',
  exercises: _elbowExercises,
);

const List<ExerciseLibraryItem> _elbowExercises = [
  ExerciseLibraryItem(
    name: 'Önkol Germe',
    description:
        'Kolun önkolunu bilek yukarı bakacak şekilde gerin. Dirsek kaslarını gevşetir.',
    sets: '3 x 30 saniye',
    difficulty: 'Kolay',
    phase: 'Akut',
    youtubeSearchTerm: 'wrist extensor stretch tennis elbow',
    rehabPhase: 'acute',
    category: 'stretch',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Eksantrik Bilek Ekstansiyonu',
    description:
        'Yavaşça bileği aşağı indirip yukarı kaldırın. Tenisçi dirseği için en etkili egzersiz.',
    sets: '3 set x 15 tekrar',
    difficulty: 'Orta',
    phase: 'Kronik',
    youtubeSearchTerm: 'eccentric wrist extension tennis elbow',
    rehabPhase: 'subacute',
    category: 'strength',
    painRule: 'Ağrı 5/10 üzerindeyse dur',
    contraindications: ['Akut tendon yırtığı'],
  ),
  ExerciseLibraryItem(
    name: 'Tyler Twist',
    description:
        'Esnek çubukla bilek rotasyonu yapılır. Lateral epikondilit tedavisinde kullanılır.',
    sets: '3 set x 15 tekrar',
    difficulty: 'Orta',
    phase: 'Kronik',
    youtubeSearchTerm: 'Tyler twist exercise tennis elbow',
    rehabPhase: 'subacute',
    category: 'strength',
    painRule: 'Ağrı 5/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Pronasyon/Supinasyon',
    description:
        'Önkol avuç içi yukarı-aşağı döndürülür. Dirsek stabilitesini artırır.',
    sets: '3 set x 15 tekrar (her yön)',
    difficulty: 'Zor',
    phase: 'Kronik',
    youtubeSearchTerm: 'forearm pronation supination exercise',
    rehabPhase: 'subacute',
    category: 'mobility',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  // Yeni eklenen egzersizler
  ExerciseLibraryItem(
    name: 'Bilek Fleksiyon Germe',
    description:
        'Kolunuzu uzatın, elinizi aşağıya bastırın ve tutun. Bilek fleksörlerini ve önkol iç kaslarını esnetir.',
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
    name: 'Bilek Ekstansiyon Germe',
    description:
        'Elinizi yukarıya doğru gerin ve diğer elinizle bastırarak tutun. Bilek ekstansörlerini ve önkol dış kaslarını esnetir.',
    sets: '3 x 30 saniye',
    difficulty: 'Kolay',
    phase: 'Akut',
    youtubeSearchTerm: 'wrist extensor stretch tennis elbow',
    rehabPhase: 'acute',
    category: 'stretch',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'İzometrik Kavrama',
    description:
        'Stres topunu ya da yumuşak bir nesneyi sıkıştırın ve 10 saniye tutun. Önkol kaslarını aktive eder.',
    sets: '3 set x 10 tekrar',
    difficulty: 'Kolay',
    phase: 'Akut',
    youtubeSearchTerm: 'isometric grip hold exercise',
    rehabPhase: 'acute',
    category: 'activation',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Towel Squeeze',
    description:
        'Rulo edilmiş havluyu sıkıştırın ve bırakın. Kavrama gücünü artırır.',
    sets: '3 set x 15 tekrar',
    difficulty: 'Kolay',
    phase: 'Kronik',
    youtubeSearchTerm: 'towel squeeze grip exercise',
    rehabPhase: 'subacute',
    category: 'strength',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Bilek Ekstansiyon Curl',
    description:
        'Önkolunuzu masaya dayayın ve bileği yavaşça kaldırıp indirin. Dirsek ekstansör kaslarını güçlendirir.',
    sets: '3 set x 15 tekrar',
    difficulty: 'Orta',
    phase: 'Rehabilitasyon',
    youtubeSearchTerm: 'wrist extension strengthening',
    rehabPhase: 'rebuilding',
    category: 'strength',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: ['Akut tendon yırtığı'],
  ),
  ExerciseLibraryItem(
    name: 'Bilek Fleksiyon Curl',
    description:
        'Önkolunuzu masaya dayayın ve bileği aşağıdan yukarıya doğru kaldırın. Dirsek fleksör kaslarını güçlendirir.',
    sets: '3 set x 15 tekrar',
    difficulty: 'Orta',
    phase: 'Rehabilitasyon',
    youtubeSearchTerm: 'wrist flexion curl exercise',
    rehabPhase: 'rebuilding',
    category: 'strength',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Hammer Rotasyonu',
    description:
        'Çekiç veya ağırlıklı nesneyi tutup önkolu döndürün. Önkol rotasyon kaslarını dengeli güçlendirir.',
    sets: '3 set x 15 tekrar',
    difficulty: 'Orta',
    phase: 'Rehabilitasyon',
    youtubeSearchTerm: 'forearm rotation hammer exercise',
    rehabPhase: 'rebuilding',
    category: 'strength',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
];
