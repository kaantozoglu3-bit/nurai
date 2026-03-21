import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../providers/auth_provider.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingXXL),
        children: [
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
            onTap: () => context.go(AppRoutes.settings),
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
