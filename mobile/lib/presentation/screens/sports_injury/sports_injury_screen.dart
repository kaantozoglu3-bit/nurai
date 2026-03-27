import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_router.dart';

class _InjuryCard {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String bodyArea;

  const _InjuryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bodyArea,
  });
}

const _kInjuryCards = [
  _InjuryCard(
    title: 'ACL — Ön Çapraz Bağ',
    subtitle: 'Diz bağ hasarı, 5 fazlı protokol',
    icon: Icons.directions_run,
    color: Color(0xFFEF4444),
    bodyArea: 'left_knee',
  ),
  _InjuryCard(
    title: 'Menisküs Yırtığı',
    subtitle: 'Konservatif veya cerrahi sonrası',
    icon: Icons.sports_soccer,
    color: Color(0xFFF97316),
    bodyArea: 'left_knee',
  ),
  _InjuryCard(
    title: 'Patellar Tendinopati',
    subtitle: 'Jumper\'s knee — Eksantrik protokol',
    icon: Icons.sports_basketball,
    color: Color(0xFFF59E0B),
    bodyArea: 'left_knee',
  ),
  _InjuryCard(
    title: 'Ayak Bileği Burkulması',
    subtitle: 'Lateral sprain rehabilitasyonu',
    icon: Icons.directions_walk,
    color: Color(0xFF22C55E),
    bodyArea: 'left_ankle',
  ),
  _InjuryCard(
    title: 'Aşil Tendinopati',
    subtitle: 'Alfredson HSR protokolü',
    icon: Icons.sports_handball,
    color: Color(0xFF10B981),
    bodyArea: 'left_ankle',
  ),
  _InjuryCard(
    title: 'Rotator Cuff Hasarı',
    subtitle: 'Omuz rotator cuff yırtığı',
    icon: Icons.sports_volleyball,
    color: Color(0xFF3B82F6),
    bodyArea: 'left_shoulder',
  ),
  _InjuryCard(
    title: 'Omuz — Bankart / SLAP',
    subtitle: 'Glenohumeral instabilite rehab',
    icon: Icons.sports_tennis,
    color: Color(0xFF6366F1),
    bodyArea: 'left_shoulder',
  ),
  _InjuryCard(
    title: 'Tenis / Golfçü Dirseği',
    subtitle: 'Tyler Twist protokolü',
    icon: Icons.sports_cricket,
    color: Color(0xFF8B5CF6),
    bodyArea: 'left_elbow',
  ),
  _InjuryCard(
    title: 'Bel / Disk Hasarı',
    subtitle: 'McGill Big 3 + Dead Bug protokolü',
    icon: Icons.airline_seat_recline_extra,
    color: Color(0xFFEC4899),
    bodyArea: 'lower_back',
  ),
  _InjuryCard(
    title: 'Kas Streni',
    subtitle: 'Grade 1-2-3 kas yırtığı rehab',
    icon: Icons.fitness_center,
    color: Color(0xFF64748B),
    bodyArea: 'lower_back',
  ),
];

class SportsInjuryScreen extends StatelessWidget {
  const SportsInjuryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => context.go(AppRoutes.bodySelector),
        ),
        title: const Row(
          children: [
            Icon(Icons.sports, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text(
              'Sporcu Rehabilitasyonu',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingL,
              AppDimensions.paddingL,
              AppDimensions.paddingL,
              AppDimensions.paddingS,
            ),
            child: Text(
              'Yaralanma tipini seç — AI seni kanıta dayalı protokolle yönlendirsin.',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              itemCount: _kInjuryCards.length,
              itemBuilder: (context, index) {
                final card = _kInjuryCards[index];
                return _InjuryCardWidget(card: card);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InjuryCardWidget extends StatelessWidget {
  final _InjuryCard card;

  const _InjuryCardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          onTap: () => context.go('/chat/${card.bodyArea}'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: card.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Icon(card.icon, color: card.color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.title,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        card.subtitle,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.textHint, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
