import '../models/exercise_library_model.dart';

const BodyAreaLibrary leftAnkleExercises = BodyAreaLibrary(
  key: 'left_ankle',
  label: 'Sol Ayak Bileği',
  exercises: _ankleExercises,
);

const BodyAreaLibrary rightAnkleExercises = BodyAreaLibrary(
  key: 'right_ankle',
  label: 'Sağ Ayak Bileği',
  exercises: _ankleExercises,
);

const List<ExerciseLibraryItem> _ankleExercises = [
  ExerciseLibraryItem(
    name: 'Alfabe Egzersizi',
    description:
        'Ayak bileğiyle havada alfabe harfleri yazın. Eklem hareketliliğini artırır.',
    sets: '2 set x alfabe baştan sona',
    difficulty: 'Kolay',
    phase: 'Akut',
    youtubeSearchTerm: 'ankle alphabet exercise ROM',
    rehabPhase: 'acute',
    category: 'mobility',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Towel Scrunching',
    description:
        'Yerde yayılmış havlu parmaklarla toplanır. Ayak iç kaslarını güçlendirir.',
    sets: '3 set x 30 saniye',
    difficulty: 'Kolay',
    phase: 'Akut',
    youtubeSearchTerm: 'towel scrunching toe exercise',
    rehabPhase: 'acute',
    category: 'strength',
    painRule: 'Ağrı artarsa dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Dorsifleksiyon Germe',
    description:
        'Theraband ile ayağı yukarı çekerek tutun. Ayak bileği dorsifleksiyonunu artırır.',
    sets: '3 set x 15 tekrar',
    difficulty: 'Orta',
    phase: 'Kronik',
    youtubeSearchTerm: 'ankle dorsiflexion resistance band',
    rehabPhase: 'rebuilding',
    category: 'strength',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Tek Ayak Denge',
    description:
        'Tek ayak üzerinde gözler açık/kapalı durun. Propriyoseptif denge geliştirir.',
    sets: '3 x 30 saniye (her ayak)',
    difficulty: 'Orta',
    phase: 'Kronik',
    youtubeSearchTerm: 'single leg balance ankle stability',
    rehabPhase: 'rebuilding',
    category: 'balance',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Gastrocnemius Germe',
    description:
        'Duvara dayayıp arka bacak düz, topuk yerde basın. Baldır kaslarını esnetir.',
    sets: '3 x 30 saniye',
    difficulty: 'Kolay',
    phase: 'Kronik',
    youtubeSearchTerm: 'gastrocnemius stretch wall',
    rehabPhase: 'subacute',
    category: 'stretch',
    painRule: 'Ağrı artarsa dur',
    contraindications: [],
  ),
  // Yeni eklenen egzersizler
  ExerciseLibraryItem(
    name: 'Ayak Bileği Pompaları',
    description:
        'Ayak bileğini yukarı-aşağı yavaşça hareket ettirin. Kan dolaşımını artırır, ödem azaltır.',
    sets: '3 set x 20 tekrar',
    difficulty: 'Kolay',
    phase: 'Akut',
    youtubeSearchTerm: 'ankle pumps exercise',
    rehabPhase: 'acute',
    category: 'mobility',
    painRule: 'Ağrı artarsa dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Buzağı Germe',
    description:
        'Duvara dayayıp arka bacağı uzatın, topuk yerde sabit kalacak şekilde geriniz. Gastrocnemius kasını esnetir.',
    sets: '3 x 30 saniye (her bacak)',
    difficulty: 'Kolay',
    phase: 'Akut',
    youtubeSearchTerm: 'calf stretch gastrocnemius',
    rehabPhase: 'acute',
    category: 'stretch',
    painRule: 'Ağrı artarsa dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Diz Bükülü Baldır Germe',
    description:
        'Duvara dayayıp arka dizi büküp topuğu yere bastırın. Soleus kasını hedefler.',
    sets: '3 x 30 saniye (her bacak)',
    difficulty: 'Kolay',
    phase: 'Kronik',
    youtubeSearchTerm: 'soleus stretch bent knee',
    rehabPhase: 'subacute',
    category: 'stretch',
    painRule: 'Ağrı artarsa dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Havlu ile Dorsifleksiyon Germe',
    description:
        'Yerde oturarak havluyu ayak tabanına koyup kendinize doğru çekin. Ayak bileği germe için güvenli yöntemdir.',
    sets: '3 x 30 saniye',
    difficulty: 'Kolay',
    phase: 'Akut',
    youtubeSearchTerm: 'towel stretch ankle dorsiflexion',
    rehabPhase: 'acute',
    category: 'stretch',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Parmak Ucu Yükselme (Calf Raise)',
    description:
        'Parmak uçlarına yükselin ve alçalın. Baldır kaslarını güçlendirir.',
    sets: '3 set x 15 tekrar',
    difficulty: 'Orta',
    phase: 'Rehabilitasyon',
    youtubeSearchTerm: 'calf raise exercise',
    rehabPhase: 'rebuilding',
    category: 'strength',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Tibialis Kaldırma',
    description:
        'Topuklara basıp parmak uçlarını yukarı kaldırın. Tibialis anterior kasını güçlendirir.',
    sets: '3 set x 15 tekrar',
    difficulty: 'Orta',
    phase: 'Rehabilitasyon',
    youtubeSearchTerm: 'tibialis anterior raise exercise',
    rehabPhase: 'rebuilding',
    category: 'strength',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
  ExerciseLibraryItem(
    name: 'Eversyon Bant ile',
    description:
        'Theraband ile ayak bileğini dışa döndürün. Ayak bileği dış rotasyon kaslarını güçlendirir.',
    sets: '3 set x 15 tekrar',
    difficulty: 'Orta',
    phase: 'Rehabilitasyon',
    youtubeSearchTerm: 'ankle eversion resistance band',
    rehabPhase: 'rebuilding',
    category: 'strength',
    painRule: 'Ağrı 4/10 üzerindeyse dur',
    contraindications: [],
  ),
];
