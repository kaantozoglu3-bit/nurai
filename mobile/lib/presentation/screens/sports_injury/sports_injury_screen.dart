import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_router.dart';

class _InjuryCard {
  final String injuryId;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _InjuryCard({
    required this.injuryId,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

const _kInjuryCards = [
  _InjuryCard(
    injuryId: 'acl',
    title: 'ACL — Ön Çapraz Bağ',
    subtitle: 'Diz bağ hasarı • 5 fazlı protokol • 9–12 ay',
    icon: Icons.directions_run,
    color: Color(0xFFEF4444),
  ),
  _InjuryCard(
    injuryId: 'meniscus',
    title: 'Menisküs Yırtığı',
    subtitle: 'Konservatif veya cerrahi sonrası • 3–6 ay',
    icon: Icons.sports_soccer,
    color: Color(0xFFF97316),
  ),
  _InjuryCard(
    injuryId: 'patellar_tendinopathy',
    title: 'Patellar Tendinopati',
    subtitle: "Jumper's knee — Eksantrik protokol • 12+ hafta",
    icon: Icons.sports_basketball,
    color: Color(0xFFF59E0B),
  ),
  _InjuryCard(
    injuryId: 'ankle_sprain',
    title: 'Ayak Bileği Burkulması',
    subtitle: 'Lateral sprain rehabilitasyonu • 3–6 hafta',
    icon: Icons.directions_walk,
    color: Color(0xFF22C55E),
  ),
  _InjuryCard(
    injuryId: 'achilles_tendinopathy',
    title: 'Aşil Tendinopati',
    subtitle: 'Alfredson HSR protokolü • 12 hafta',
    icon: Icons.sports_handball,
    color: Color(0xFF10B981),
  ),
  _InjuryCard(
    injuryId: 'rotator_cuff',
    title: 'Rotator Cuff Hasarı',
    subtitle: 'Omuz rotator cuff yırtığı • 3–6 ay',
    icon: Icons.sports_volleyball,
    color: Color(0xFF3B82F6),
  ),
  _InjuryCard(
    injuryId: 'bankart_slap',
    title: 'Omuz — Bankart / SLAP',
    subtitle: 'Glenohumeral instabilite rehab • 6–9 ay',
    icon: Icons.sports_tennis,
    color: Color(0xFF6366F1),
  ),
  _InjuryCard(
    injuryId: 'tennis_elbow',
    title: 'Tenis / Golfçü Dirseği',
    subtitle: 'Tyler Twist protokolü • 6–12 hafta',
    icon: Icons.sports_cricket,
    color: Color(0xFF8B5CF6),
  ),
  _InjuryCard(
    injuryId: 'lumbar_disc',
    title: 'Bel / Disk Hasarı',
    subtitle: 'McGill Big 3 + Dead Bug protokolü',
    icon: Icons.airline_seat_recline_extra,
    color: Color(0xFFEC4899),
  ),
  _InjuryCard(
    injuryId: 'muscle_strain',
    title: 'Hamstring / Adduktör Strain',
    subtitle: 'Nordic + Copenhagen protokolü • 1–8 hafta',
    icon: Icons.fitness_center,
    color: Color(0xFF64748B),
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
            child: const Text(
              'Yaralanma tipini seç → faz seç → egzersiz listesi veya AI rehberliği.',
              style: TextStyle(
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
          onTap: () => context.go('/rehab-phase/${card.injuryId}'),
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
