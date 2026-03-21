import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/services/notification_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';

const String _termsUrl = 'https://nurai.app/terms';
const String _feedbackEmail = 'destek@nurai.app';

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    return;
  }
}

Future<void> _showNotificationDialog(BuildContext context) async {
  final svc = NotificationService.instance;
  final settings = await svc.getReminderSettings();
  if (!context.mounted) return;

  TimeOfDay selected = TimeOfDay(hour: settings.hour, minute: settings.minute);
  bool enabled = settings.enabled;

  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text(
          'Egzersiz Hatırlatıcısı',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Günlük Hatırlatıcı',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
              value: enabled,
              onChanged: (v) => setState(() => enabled = v),
              activeThumbColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
            if (enabled) ...[
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Saat',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
                trailing: Text(
                  '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary),
                ),
                onTap: () async {
                  final t = await showTimePicker(
                    context: ctx,
                    initialTime: selected,
                  );
                  if (t != null) setState(() => selected = t);
                },
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () async {
              if (enabled) {
                final granted = await svc.requestPermission();
                if (granted) {
                  await svc.scheduleDaily(selected.hour, selected.minute);
                }
              } else {
                await svc.cancel();
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _launchEmail(String email) async {
  final uri = Uri(scheme: 'mailto', path: email, queryParameters: {
    'subject': 'Nurai Uygulama Geri Bildirimi',
  });
  if (!await launchUrl(uri)) {
    return;
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: const Text('Profil & Ayarlar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingXXL),
        children: [
          // Profile header
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        (user?.displayName ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  user?.displayName ?? '',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
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
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (user?.isPremium ?? false)
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        (user?.isPremium ?? false)
                            ? Icons.star
                            : Icons.star_border,
                        size: 14,
                        color: (user?.isPremium ?? false)
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        (user?.isPremium ?? false) ? 'Premium' : 'Ücretsiz Plan',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: (user?.isPremium ?? false)
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Sections
          _SectionHeader(title: 'Hesap'),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Profil Bilgileri',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.history,
            title: 'Geçmiş Analizler',
            onTap: () => context.go(AppRoutes.history),
          ),
          _SettingsTile(
            icon: Icons.star_outline,
            title: 'Abonelik Yönetimi',
            subtitle: 'Ücretsiz Plan',
            onTap: () => context.go(AppRoutes.paywall),
          ),

          const SizedBox(height: 8),
          _SectionHeader(title: 'Uygulama'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Bildirimler',
            onTap: () => _showNotificationDialog(context),
          ),
          _SettingsTile(
            icon: Icons.language_outlined,
            title: 'Dil',
            subtitle: 'Türkçe',
            onTap: () {},
          ),

          const SizedBox(height: 8),
          _SectionHeader(title: 'Destek & Yasal'),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Yardım & SSS',
            onTap: () => context.go(AppRoutes.helpSupport),
          ),
          _SettingsTile(
            icon: Icons.feedback_outlined,
            title: 'Geri Bildirim',
            onTap: () => _launchEmail(_feedbackEmail),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Gizlilik Politikası',
            onTap: () => context.go(AppRoutes.privacyPolicy),
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Kullanım Şartları',
            onTap: () => _launchUrl(_termsUrl),
          ),

          const SizedBox(height: 8),
          _SectionHeader(title: 'Hesap İşlemleri'),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Çıkış Yap',
            color: AppColors.error,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text(
                    'Çıkış Yap',
                    style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
                  ),
                  content: const Text(
                    'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?',
                    style: TextStyle(fontFamily: 'Inter'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Vazgeç'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Çıkış Yap',
                          style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) context.go(AppRoutes.login);
              }
            },
          ),
          _SettingsTile(
            icon: Icons.delete_outline,
            title: 'Hesabı Sil',
            subtitle: 'Tüm verileriniz 30 gün içinde silinir',
            color: AppColors.error,
            onTap: () {},
          ),
          const SizedBox(height: 32),

          // Version
          const Center(
            child: Text(
              'PainRelief AI v1.0.0',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? AppColors.textPrimary;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: 2,
        ),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: tileColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: tileColor, size: 18),
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
        trailing: Icon(Icons.chevron_right,
            color: AppColors.textHint, size: 18),
        onTap: onTap,
      ),
    );
  }
}
