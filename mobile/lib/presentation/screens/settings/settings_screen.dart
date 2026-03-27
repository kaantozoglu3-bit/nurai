import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../providers/locale_provider.dart';
import '../../providers/settings_provider.dart';
import '../../../core/router/app_router.dart';
import 'widgets/profile_section.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  bool _controllersPopulated = false;

  @override
  void dispose() {
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _populateControllers(SettingsState s) {
    if (_controllersPopulated) return;
    _ageCtrl.text = s.age;
    _heightCtrl.text = s.height;
    _weightCtrl.text = s.weight;
    _controllersPopulated = true;
  }

  Future<void> _saveProfile(SettingsState s) async {
    await ref.read(settingsProvider.notifier).saveProfile({
      'age': _ageCtrl.text,
      'height': _heightCtrl.text,
      'weight': _weightCtrl.text,
      'fitnessLevel': s.fitnessLevel,
      'injuries': s.injuries,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil kaydedildi')),
      );
    }
  }


  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Material(
        type: MaterialType.transparency,
        child: AlertDialog(
          title: const Text('Hesabı Sil'),
          content: const Text(
            'Tüm verileriniz kalıcı olarak silinecek. '
            'Bu işlem geri alınamaz. Devam etmek istiyor musunuz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Sil'),
            ),
          ],
        ),
      ),
    );
    if (confirm != true) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final batch = FirebaseFirestore.instance.batch();
      final analyses = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('analyses')
          .get();
      for (final d in analyses.docs) {
        batch.delete(d.reference);
      }
      final badges = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('badges')
          .get();
      for (final d in badges.docs) {
        batch.delete(d.reference);
      }
      batch.delete(
          FirebaseFirestore.instance.collection('users').doc(uid));
      await batch.commit();
    }

    await FirebaseAuth.instance.currentUser?.delete();
    if (mounted) context.go(AppRoutes.login);
  }


  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.radiusItem),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withValues(alpha: 0.12),
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusIcon),
          ),
          child: Icon(
            icon,
            color: iconColor ?? AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              )
            : null,
        trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncSettings = ref.watch(settingsProvider);

    return asyncSettings.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        appBar: _buildAppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                const Text('Ayarlar yüklenemedi.'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(settingsProvider.notifier).reload(),
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (s) {
        _populateControllers(s);
        final notifier = ref.read(settingsProvider.notifier);

        return Scaffold(
          appBar: _buildAppBar(),
          body: ListView(
            children: [
              const SizedBox(height: 8),

              // ── Profil Kartı ────────────────────────────────────────────
              _buildProfileCard(s),

              // ── HESAP Grubu ─────────────────────────────────────────────
              _buildSectionHeader('Hesap'),
              _buildSettingsTile(
                icon: Icons.person,
                title: 'Profil Bilgileri',
                subtitle: 'Yaş, boy, kilo, fitness seviyesi',
                onTap: () => _showProfileEditDialog(s, notifier),
              ),
              _buildSettingsTile(
                icon: Icons.star,
                title: 'Abonelik',
                subtitle: 'Premium plan\'a yükselt',
                onTap: () => context.go(AppRoutes.paywall),
              ),
              _buildSettingsTile(
                icon: Icons.notifications,
                title: 'Bildirim Ayarları',
                subtitle: 'Egzersiz ve ağrı günlüğü hatırlatıcıları',
                onTap: () => context.go(AppRoutes.notifications),
              ),
              const SizedBox(height: 4),

              // ── UYGULAMA Grubu ──────────────────────────────────────────
              _buildSectionHeader('Uygulama'),
              _buildSettingsTile(
                icon: Icons.language,
                title: 'Dil',
                subtitle: ref.watch(localeProvider).languageCode == 'tr'
                    ? 'Türkçe'
                    : 'English',
                trailing: PopupMenuButton<String>(
                  initialValue: ref.watch(localeProvider).languageCode,
                  onSelected: (v) {
                    ref.read(localeProvider.notifier).setLocale(v);
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'tr', child: Text('Türkçe')),
                    const PopupMenuItem(value: 'en', child: Text('English')),
                  ],
                  child: const Icon(Icons.chevron_right, size: 20),
                ),
                onTap: null,
              ),
              _buildSettingsTile(
                icon: Icons.brightness_7,
                title: 'Tema',
                subtitle: 'Açık',
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.privacy_tip,
                title: 'Gizlilik Politikası',
                onTap: () => context.go(AppRoutes.privacyPolicy),
              ),
              _buildSettingsTile(
                icon: Icons.help,
                title: 'Yardım ve Destek',
                onTap: () => _sendSupportEmail(),
              ),
              const SizedBox(height: 4),

              // ── GÜVENLİK Grubu ──────────────────────────────────────────
              _buildSectionHeader('Güvenlik'),
              _buildSettingsTile(
                icon: Icons.lock,
                title: 'Şifre Değiştir',
                onTap: () => _sendPasswordReset(),
              ),
              _buildSettingsTile(
                icon: Icons.delete_forever,
                title: 'Hesabı Sil',
                subtitle: 'Tüm verileriniz kalıcı olarak silinir',
                iconColor: AppColors.error,
                onTap: _deleteAccount,
              ),
              const SizedBox(height: 40),

              // ── Footer ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 24),
                child: Text(
                  'MADE WITH ❤️ FOR N.A'.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Ayarlar',
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildProfileCard(SettingsState s) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Kullanıcı';
    final email = user?.email ?? '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          boxShadow: const [AppDimensions.cardShadow],
        ),
        padding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: AppColors.secondaryContainer,
                      width: 4,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 48,
                    color: AppColors.surface,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Edit profile
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Profili Düzenle'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusChip),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: FloatingActionButton.small(
                onPressed: () => _showProfileEditDialog(
                  s,
                  ref.read(settingsProvider.notifier),
                ),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.edit, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showProfileEditDialog(
    SettingsState s,
    dynamic notifier,
  ) async {
    return showDialog(
      context: context,
      builder: (ctx) => Material(
        type: MaterialType.transparency,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ProfileSection(
              ageCtrl: _ageCtrl,
              heightCtrl: _heightCtrl,
              weightCtrl: _weightCtrl,
              fitnessLevel: s.fitnessLevel,
              injuries: s.injuries,
              onFitnessLevelChanged: notifier.setFitnessLevel,
              onInjuryAdded: notifier.addInjury,
              onInjuryRemoved: notifier.removeInjury,
              onSave: () {
                _saveProfile(s);
                Navigator.pop(ctx);
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendPasswordReset() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Şifre sıfırlama e-postası $email adresine gönderildi.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _sendSupportEmail() async {
    // Implementation for sending support email
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Destek e-postası yakında')),
    );
  }
}
