import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/services/athlete_service.dart';
import '../../../data/sports_injury_library/sports_injury_data.dart';
import '../../../data/sports_injury_library/sports_injury_model.dart';

class SportsExercisesScreen extends StatefulWidget {
  final String injuryId;
  final int phaseNumber;

  const SportsExercisesScreen({
    super.key,
    required this.injuryId,
    required this.phaseNumber,
  });

  @override
  State<SportsExercisesScreen> createState() => _SportsExercisesScreenState();
}

class _SportsExercisesScreenState extends State<SportsExercisesScreen> {
  final Set<int> _completed = {};
  bool _loading = true;
  late SportsInjury _injury;
  late RehabPhase _phase;

  @override
  void initState() {
    super.initState();
    final injury = kSportsInjuries[widget.injuryId];
    _injury = injury!;
    _phase = _injury.phases.firstWhere(
      (p) => p.phaseNumber == widget.phaseNumber,
      orElse: () => _injury.phases.first,
    );
    _loadCompletions();
  }

  Future<void> _loadCompletions() async {
    final keys = await AthleteService.fetchTodayCompletions(
      injuryId: widget.injuryId,
      phaseNumber: widget.phaseNumber,
    );
    // Map field keys back to local indices
    for (int i = 0; i < _phase.exercises.length; i++) {
      final name = _phase.exercises[i].name.replaceAll(' ', '_');
      final key = '${widget.injuryId}_phase${widget.phaseNumber}_$name';
      if (keys.contains(key)) {
        _completed.add(i);
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _toggleComplete(int index) async {
    final exercise = _phase.exercises[index];
    final isNowComplete = !_completed.contains(index);

    setState(() {
      if (isNowComplete) {
        _completed.add(index);
      } else {
        _completed.remove(index);
      }
    });

    if (isNowComplete) {
      await AthleteService.logExerciseCompletion(
        injuryId: widget.injuryId,
        phaseNumber: widget.phaseNumber,
        exerciseName: exercise.name,
      );
    }
  }

  Future<void> _openYouTube(String searchTerm) async {
    final uri = Uri.parse(
      'https://www.youtube.com/results?search_query=${Uri.encodeComponent(searchTerm)}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('YouTube açılamadı')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _completed.length;
    final totalCount = _phase.exercises.length;
    final color = _injury.color;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Faz ${_phase.phaseNumber} — ${_phase.title}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              _phase.timeRange,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Progress bar
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bugünkü İlerleme',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '$completedCount / $totalCount',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: totalCount > 0 ? completedCount / totalCount : 0,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Exercise list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    itemCount: _phase.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _phase.exercises[index];
                      final isDone = _completed.contains(index);
                      return _ExerciseCard(
                        exercise: exercise,
                        isDone: isDone,
                        color: color,
                        onToggle: () => _toggleComplete(index),
                        onYouTube: () => _openYouTube(exercise.youtubeSearchTerm),
                      );
                    },
                  ),
                ),

                // Completion banner
                if (completedCount == totalCount && totalCount > 0)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(AppDimensions.paddingL),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Harika! Tüm egzersizleri tamamladın 🎉',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

// ─── Exercise Card ────────────────────────────────────────────────────────────

class _ExerciseCard extends StatefulWidget {
  final RehabExercise exercise;
  final bool isDone;
  final Color color;
  final VoidCallback onToggle;
  final VoidCallback onYouTube;

  const _ExerciseCard({
    required this.exercise,
    required this.isDone,
    required this.color,
    required this.onToggle,
    required this.onYouTube,
  });

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  bool _expanded = false;

  Color _difficultyColor(String diff) {
    switch (diff) {
      case 'Kolay':
        return const Color(0xFF22C55E);
      case 'Zor':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    final diffColor = _difficultyColor(exercise.difficulty);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.isDone
              ? AppColors.primary.withValues(alpha: 0.04)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: widget.isDone
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            // Main row
            InkWell(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // Completion checkbox
                    GestureDetector(
                      onTap: widget.onToggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: widget.isDone
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: widget.isDone
                                ? AppColors.primary
                                : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: widget.isDone
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Name + sets
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: widget.isDone
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                              decoration: widget.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                exercise.sets,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: diffColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  exercise.difficulty,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: diffColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // YouTube button
                    IconButton(
                      onPressed: widget.onYouTube,
                      icon: const Icon(Icons.play_circle_outline,
                          color: Color(0xFFFF0000), size: 24),
                      tooltip: 'YouTube\'da ara',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),

                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textHint,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            // Expanded details
            if (_expanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.description,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_outlined,
                            size: 14, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            exercise.painRule,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: Color(0xFFF59E0B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
