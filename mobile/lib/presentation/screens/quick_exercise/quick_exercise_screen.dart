import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/exercise_library_model.dart';
import '../../providers/quick_exercise_provider.dart';

class QuickExerciseScreen extends ConsumerStatefulWidget {
  const QuickExerciseScreen({super.key});

  @override
  ConsumerState<QuickExerciseScreen> createState() =>
      _QuickExerciseScreenState();
}

class _QuickExerciseScreenState extends ConsumerState<QuickExerciseScreen> {
  late final List<ExerciseLibraryItem> _exercises;
  int _current = 0;
  int _secondsLeft = 30;
  bool _isRunning = false;
  bool _allDone = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _exercises = getTodayExercises();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 1) {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
          _secondsLeft = 0;
        });
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _next() {
    _timer?.cancel();
    if (_current < _exercises.length - 1) {
      setState(() {
        _current++;
        _secondsLeft = 30;
        _isRunning = false;
      });
    } else {
      // All exercises complete
      ref.read(quickExerciseProvider.notifier).markComplete();
      setState(() => _allDone = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 22, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Hızlı Egzersiz — ${getTodayAreaLabel()}',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _allDone ? _DoneView(onClose: () => context.pop()) : _ExerciseView(
        exercise: _exercises[_current],
        current: _current,
        total: _exercises.length,
        secondsLeft: _secondsLeft,
        isRunning: _isRunning,
        onStart: _startTimer,
        onNext: _next,
      ),
    );
  }
}

// ─── Exercise view ────────────────────────────────────────────────────────────

class _ExerciseView extends StatelessWidget {
  final ExerciseLibraryItem exercise;
  final int current;
  final int total;
  final int secondsLeft;
  final bool isRunning;
  final VoidCallback onStart;
  final VoidCallback onNext;

  const _ExerciseView({
    required this.exercise,
    required this.current,
    required this.total,
    required this.secondsLeft,
    required this.isRunning,
    required this.onStart,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = !isRunning && secondsLeft == 0;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingXXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          Row(
            children: List.generate(total, (i) => Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
                decoration: BoxDecoration(
                  color: i <= current ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            )),
          ),
          const SizedBox(height: 8),
          Text(
            '${current + 1} / $total',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),

          // Exercise name
          Text(
            exercise.name,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Badges
          Row(
            children: [
              _Badge(label: exercise.difficulty, color: AppColors.secondary),
              const SizedBox(width: 8),
              _Badge(label: exercise.phase, color: AppColors.primary),
              const SizedBox(width: 8),
              _Badge(label: exercise.sets, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 20),

          // Description card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              exercise.description,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ),
          const Spacer(),

          // Timer circle
          Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: secondsLeft / 30,
                    strokeWidth: 6,
                    backgroundColor: AppColors.border,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  Text(
                    isDone ? '✓' : '$secondsLeft',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: isDone ? 36 : 28,
                      fontWeight: FontWeight.w700,
                      color: isDone ? AppColors.success : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Action button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isDone ? onNext : (isRunning ? null : onStart),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDone ? AppColors.success : AppColors.primary,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.4),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
              ),
              child: Text(
                isDone
                    ? (current < 2 ? 'Sonraki Egzersiz →' : 'Tamamla 🎉')
                    : (isRunning ? 'Süre Sayılıyor…' : 'Başlat'),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ─── Done view ────────────────────────────────────────────────────────────────

class _DoneView extends StatelessWidget {
  final VoidCallback onClose;
  const _DoneView({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 80, color: AppColors.success),
            const SizedBox(height: 20),
            const Text(
              'Harika İş!',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Bugünkü hızlı egzersizini tamamladın.\nYarın yeni egzersizler seni bekliyor!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusS),
                  ),
                ),
                child: const Text(
                  'Ana Sayfaya Dön',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Badge widget ─────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
