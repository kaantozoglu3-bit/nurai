class ExerciseLibraryItem {
  final String name;
  final String description;
  final String sets;
  final String difficulty; // 'Kolay' | 'Orta' | 'Zor'
  final String phase; // 'Akut' | 'Kronik' | 'Rehabilitasyon'
  final String youtubeSearchTerm;
  final String rehabPhase; // 'acute' | 'subacute' | 'rebuilding' | 'return_to_sport'
  final String category; // 'mobility' | 'stretch' | 'activation' | 'strength' | 'stability' | 'balance'
  final String painRule;
  final List<String> contraindications;

  const ExerciseLibraryItem({
    required this.name,
    required this.description,
    required this.sets,
    required this.difficulty,
    required this.phase,
    this.youtubeSearchTerm = '',
    this.rehabPhase = 'subacute',
    this.category = 'mobility',
    this.painRule = 'Ağrı artarsa dur',
    this.contraindications = const [],
  });
}

class BodyAreaLibrary {
  final String key;
  final String label;
  final List<ExerciseLibraryItem> exercises;

  const BodyAreaLibrary({
    required this.key,
    required this.label,
    required this.exercises,
  });
}
