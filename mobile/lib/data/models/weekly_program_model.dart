import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Sub-models ───────────────────────────────────────────────────────────────

class ProgramExercise {
  final String name;
  final String sets;
  final String duration;
  final String description;
  final String? videoQuery;

  const ProgramExercise({
    required this.name,
    required this.sets,
    required this.duration,
    required this.description,
    this.videoQuery,
  });

  factory ProgramExercise.fromMap(Map<String, dynamic> m) => ProgramExercise(
        name: m['name'] as String? ?? '',
        sets: m['sets'] as String? ?? '',
        duration: m['duration'] as String? ?? '',
        description: m['description'] as String? ?? '',
        videoQuery: m['videoQuery'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'sets': sets,
        'duration': duration,
        'description': description,
        if (videoQuery != null) 'videoQuery': videoQuery,
      };
}

class ProgramDay {
  final int dayNumber;
  final String dayName;
  final List<ProgramExercise> exercises;

  const ProgramDay({
    required this.dayNumber,
    required this.dayName,
    required this.exercises,
  });

  factory ProgramDay.fromMap(Map<String, dynamic> m) => ProgramDay(
        dayNumber: (m['dayNumber'] as num?)?.toInt() ?? 1,
        dayName: m['dayName'] as String? ?? '',
        exercises: (m['exercises'] as List? ?? [])
            .map((e) => ProgramExercise.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'dayNumber': dayNumber,
        'dayName': dayName,
        'exercises': exercises.map((e) => e.toMap()).toList(),
      };
}

class ProgramWeek {
  final int weekNumber;
  final String title;
  final String focus;
  final List<ProgramDay> days;

  const ProgramWeek({
    required this.weekNumber,
    required this.title,
    required this.focus,
    required this.days,
  });

  factory ProgramWeek.fromMap(Map<String, dynamic> m) => ProgramWeek(
        weekNumber: (m['weekNumber'] as num?)?.toInt() ?? 1,
        title: m['title'] as String? ?? '',
        focus: m['focus'] as String? ?? '',
        days: (m['days'] as List? ?? [])
            .map((d) => ProgramDay.fromMap(Map<String, dynamic>.from(d as Map)))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'weekNumber': weekNumber,
        'title': title,
        'focus': focus,
        'days': days.map((d) => d.toMap()).toList(),
      };
}

// ─── Top-level model ──────────────────────────────────────────────────────────

class WeeklyProgramModel {
  final DateTime generatedAt;
  final List<String> targetAreas;
  final List<ProgramWeek> weeks;
  final List<String> completedDays; // e.g. ['W1D1', 'W1D2']

  const WeeklyProgramModel({
    required this.generatedAt,
    required this.targetAreas,
    required this.weeks,
    this.completedDays = const [],
  });

  /// Key for a completed day: 'W{week}D{day}'
  static String dayKey(int week, int day) => 'W${week}D$day';

  bool isDayCompleted(int week, int day) =>
      completedDays.contains(dayKey(week, day));

  WeeklyProgramModel copyWith({
    DateTime? generatedAt,
    List<String>? targetAreas,
    List<ProgramWeek>? weeks,
    List<String>? completedDays,
  }) =>
      WeeklyProgramModel(
        generatedAt: generatedAt ?? this.generatedAt,
        targetAreas: targetAreas ?? this.targetAreas,
        weeks: weeks ?? this.weeks,
        completedDays: completedDays ?? this.completedDays,
      );

  factory WeeklyProgramModel.fromMap(Map<String, dynamic> m) {
    final ts = m['generatedAt'];
    final genAt = ts is Timestamp
        ? ts.toDate()
        : DateTime.tryParse(ts?.toString() ?? '') ?? DateTime.now();

    return WeeklyProgramModel(
      generatedAt: genAt,
      targetAreas: List<String>.from(m['targetAreas'] as List? ?? []),
      weeks: (m['weeks'] as List? ?? [])
          .map((w) => ProgramWeek.fromMap(Map<String, dynamic>.from(w as Map)))
          .toList(),
      completedDays:
          List<String>.from(m['completedDays'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'generatedAt': Timestamp.fromDate(generatedAt),
        'targetAreas': targetAreas,
        'weeks': weeks.map((w) => w.toMap()).toList(),
        'completedDays': completedDays,
      };
}
