import 'package:flutter/material.dart';

// ─── SportsInjury ─────────────────────────────────────────────────────────────

class SportsInjury {
  final String id;
  final String name;
  final String bodyArea;
  final String recoveryTime;
  final List<RehabPhase> phases;
  final IconData icon;
  final Color color;

  const SportsInjury({
    required this.id,
    required this.name,
    required this.bodyArea,
    required this.recoveryTime,
    required this.phases,
    required this.icon,
    required this.color,
  });
}

// ─── RehabPhase ───────────────────────────────────────────────────────────────

class RehabPhase {
  final int phaseNumber;
  final String title;
  final String timeRange;
  final List<String> goals;
  final List<RehabExercise> exercises;

  const RehabPhase({
    required this.phaseNumber,
    required this.title,
    required this.timeRange,
    required this.goals,
    required this.exercises,
  });
}

// ─── RehabExercise ────────────────────────────────────────────────────────────

class RehabExercise {
  final String name;
  final String sets;
  final String difficulty;
  final String youtubeSearchTerm;
  final String description;
  final String painRule;

  const RehabExercise({
    required this.name,
    required this.sets,
    required this.difficulty,
    required this.youtubeSearchTerm,
    required this.description,
    required this.painRule,
  });
}
