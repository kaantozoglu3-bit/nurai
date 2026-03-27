import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../../data/services/athlete_service.dart';
import '../../../data/services/profile_service.dart';
import '../../../data/sports_injury_library/sports_injury_data.dart';
import '../../../data/sports_injury_library/sports_injury_model.dart';

class RehabPhaseScreen extends StatelessWidget {
  final String injuryId;

  const RehabPhaseScreen({super.key, required this.injuryId});

  @override
  Widget build(BuildContext context) {
    final injury = kSportsInjuries[injuryId];
    if (injury == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: const Center(child: Text('Sakatlık bulunamadı.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => context.go(AppRoutes.sportsInjury),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: injury.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(injury.icon, color: injury.color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                injury.name,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recovery info header
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(AppDimensions.paddingL),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: injury.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(color: injury.color.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, color: injury.color, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Tahmini iyileşme süresi: ${injury.recoveryTime}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: injury.color,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
            child: Text(
              'Hangi fazdasın?',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
            child: Text(
              'Fazı seç → egzersiz listesi ve AI rehberliği.',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Phase cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              itemCount: injury.phases.length,
              itemBuilder: (context, index) {
                final phase = injury.phases[index];
                return _PhaseCard(
                  injury: injury,
                  phase: phase,
                  onExercises: () => context.go(
                    '/sports-exercises/${injury.id}/${phase.phaseNumber}',
                  ),
                  onAIChat: () => _startAIChat(context, injury, phase),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startAIChat(
    BuildContext context,
    SportsInjury injury,
    RehabPhase phase,
  ) async {
    // Save context to profile so chat_provider picks it up
    await AthleteService.saveAthleteProfile(
      injuryType: injury.name,
      currentPhase: phase.phaseNumber,
    );

    // Also update the secure profile blob for chat_provider._buildProfile()
    final profile = await ProfileService.loadProfile();
    final updated = Map<String, dynamic>.from(profile)
      ..['injuryType'] = injury.name
      ..['currentPhase'] = 'Faz ${phase.phaseNumber} — ${phase.title}'
      ..['userType'] = 'athlete';
    await ProfileService.saveProfile(updated);

    if (context.mounted) {
      context.go('/chat/${injury.bodyArea}');
    }
  }
}

// ─── Phase Card ───────────────────────────────────────────────────────────────

class _PhaseCard extends StatefulWidget {
  final SportsInjury injury;
  final RehabPhase phase;
  final VoidCallback onExercises;
  final VoidCallback onAIChat;

  const _PhaseCard({
    required this.injury,
    required this.phase,
    required this.onExercises,
    required this.onAIChat,
  });

  @override
  State<_PhaseCard> createState() => _PhaseCardState();
}

class _PhaseCardState extends State<_PhaseCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final phase = widget.phase;
    final color = widget.injury.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(
                color: _expanded ? color.withValues(alpha: 0.5) : AppColors.border,
              ),
            ),
            child: Column(
              children: [
                // Header row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${phase.phaseNumber}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              phase.title,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              phase.timeRange,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                    ],
                  ),
                ),

                // Expanded: goals + action buttons
                if (_expanded) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Goals
                        const Text(
                          'Hedefler:',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...phase.goals.map((g) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.check_circle_outline,
                                      size: 14, color: color),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      g,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: 12),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: widget.onExercises,
                                icon: const Icon(Icons.fitness_center, size: 16),
                                label: const Text('Egzersizler'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: color,
                                  side: BorderSide(color: color),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  textStyle: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: widget.onAIChat,
                                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                label: const Text('AI ile Konuş'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: color,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  elevation: 0,
                                  textStyle: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
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
        ),
      ),
    );
  }
}
