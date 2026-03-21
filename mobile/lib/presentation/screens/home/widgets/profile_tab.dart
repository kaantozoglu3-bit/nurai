import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../data/services/profile_service.dart';
import '../../../providers/auth_provider.dart';

final _profileCompletionProvider =
    FutureProvider.autoDispose<double>((ref) async {
  final profile = await ProfileService.loadProfile();
  const fields = [
    'age',
    'gender',
    'height',
    'weight',
    'fitnessLevel',
    'goal',
  ];
  final completed = fields
      .where((f) =>
          profile[f] != null && profile[f].toString().trim().isNotEmpty)
      .length;
  return completed / fields.length;
});

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  Widget _buildCompletionBar(double pct) {
    if (pct >= 1.0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Profil Tamamlama',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '%${(pct * 100).toInt()}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: AppColors.border,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Profilini tamamla, daha iyi öneriler al →',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final completionAsync = ref.watch(_profileCompletionProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingXXL),
        children: [
          // Profil tamamlama çubuğu
          completionAsync.when(
            data: (pct) => _buildCompletionBar(pct),
            loading: () => const SizedBox.shrink(),
            error: (e, _) => const SizedBox.shrink(),
          ),
          // Avatar
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    (user?.displayName ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.displayName ?? '',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          ProfileTile(
            icon: Icons.history,
            title: 'Geçmiş Analizler',
            onTap: () => context.go(AppRoutes.history),
          ),
          ProfileTile(
            icon: Icons.medical_services_outlined,
            title: 'Fizyoterapist Bul',
            subtitle: 'Uzman fizyoterapistlerle bağlan',
            onTap: () => context.go(AppRoutes.marketplace),
          ),
          ProfileTile(
            icon: Icons.star_outline,
            title: 'Premium\'a Geç',
            subtitle: 'Sınırsız analiz ve özellikler',
            onTap: () => context.go(AppRoutes.paywall),
            color: AppColors.primary,
          ),
          const Divider(height: 32),
          ProfileTile(
            icon: Icons.settings_outlined,
            title: 'Ayarlar',
            onTap: () => context.go(AppRoutes.settings),
          ),
          ProfileTile(
            icon: Icons.help_outline,
            title: 'Yardım & Destek',
            onTap: () => context.go(AppRoutes.helpSupport),
          ),
          ProfileTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Gizlilik Politikası',
            onTap: () => context.go(AppRoutes.privacyPolicy),
          ),
          const Divider(height: 32),
          ProfileTile(
            icon: Icons.logout,
            title: 'Çıkış Yap',
            color: AppColors.error,
            onTap: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final VoidCallback onTap;

  const ProfileTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? AppColors.textPrimary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: tileColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: tileColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: tileColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: Icon(Icons.chevron_right, color: AppColors.textHint, size: 18),
      onTap: onTap,
    );
  }
}
