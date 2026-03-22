import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/services/badge_service.dart';
import '../../providers/locale_provider.dart';
import '../../providers/settings_provider.dart';
import '../../../core/router/app_router.dart';
import 'widgets/badges_section.dart';
import 'widgets/goals_section.dart';
import 'widgets/notification_section.dart';
import 'widgets/profile_section.dart';
import 'widgets/security_links_section.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // UI-specific controllers — stay in the widget
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

  /// Populate text controllers once when data first loads.
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

  Future<void> _saveGoal(SettingsState s) async {
    await ref.read(settingsProvider.notifier).saveGoal(s.weeklyGoal);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hedef kaydedildi')),
      );
    }
  }

  Future<void> _saveNotifSettings(SettingsState s) async {
    await ref.read(settingsProvider.notifier).saveNotifSettings(
          exerciseEnabled: s.exerciseNotifEnabled,
          exerciseTime: s.exerciseTime,
          painLogEnabled: s.painLogNotifEnabled,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bildirim ayarları kaydedildi')),
      );
    }
  }

  Future<void> _exportData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('analyses')
        .orderBy('createdAt', descending: true)
        .get();

    final data = snap.docs.map((d) => d.data()).toList();
    final jsonStr = const JsonEncoder.withIndent('  ').convert({
      'exportDate': DateTime.now().toIso8601String(),
      'userId': uid,
      'analyses': data,
    });

    await Share.share(jsonStr, subject: 'Nurai Verilerim');
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
              style: TextButton.styleFrom(foregroundColor: Colors.red),
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

  void _shareAchievement(SettingsState s) {
    final earnedNames = BadgeService.allBadges
        .where((b) => s.earnedBadges.contains(b.id))
        .map((b) => '${b.icon} ${b.name}')
        .join('\n');

    Share.share(
      'Nurai ile ${s.totalExercises} egzersiz tamamladım! 🏆\n'
      'En uzun seri: ${s.longestStreak} gün\n\n'
      'Rozetlerim:\n$earnedNames\n\n'
      'Sen de dene: nurai.app',
      subject: 'Nurai Başarılarım',
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final asyncSettings = ref.watch(settingsProvider);

    return asyncSettings.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        appBar: AppBar(title: const Text('Ayarlar')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
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
          appBar: AppBar(title: const Text('Ayarlar')),
          body: ListView(
            children: [
              // ── BÖLÜM 1: Profil Düzenleme ────────────────────────────
              _sectionHeader('Profil Düzenleme'),
              ProfileSection(
                ageCtrl: _ageCtrl,
                heightCtrl: _heightCtrl,
                weightCtrl: _weightCtrl,
                fitnessLevel: s.fitnessLevel,
                injuries: s.injuries,
                onFitnessLevelChanged: notifier.setFitnessLevel,
                onInjuryAdded: notifier.addInjury,
                onInjuryRemoved: notifier.removeInjury,
                onSave: () => _saveProfile(s),
              ),

              // ── BÖLÜM 2: Bildirimler ─────────────────────────────────
              _sectionHeader('Bildirimler'),
              NotificationSection(
                exerciseNotifEnabled: s.exerciseNotifEnabled,
                exerciseTime: s.exerciseTime,
                painLogNotifEnabled: s.painLogNotifEnabled,
                painLogTime: s.painLogTime,
                onExerciseNotifChanged: notifier.setExerciseNotifEnabled,
                onExerciseTimeChanged: notifier.setExerciseTime,
                onPainLogNotifChanged: notifier.setPainLogNotifEnabled,
                onPainLogTimeChanged: notifier.setPainLogTime,
                onSave: () => _saveNotifSettings(s),
              ),

              // Dedicated notification settings screen link
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text(
                  'Bildirim Ayarları',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14),
                ),
                subtitle: const Text(
                  'Egzersiz ve ağrı günlüğü hatırlatıcıları',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () => context.go(AppRoutes.notifications),
              ),

              // ── BÖLÜM 3: Hedefler ────────────────────────────────────
              _sectionHeader('Hedefler'),
              GoalsSection(
                weeklyGoal: s.weeklyGoal,
                onChanged: notifier.setWeeklyGoal,
                onSave: () => _saveGoal(s),
              ),

              // ── BÖLÜM 4: İlerleme Özeti ──────────────────────────────
              _sectionHeader('İlerleme Özeti'),
              ListTile(
                leading: const Icon(Icons.fitness_center),
                title: const Text('Toplam Egzersiz'),
                trailing: Text('${s.totalExercises}'),
              ),
              ListTile(
                leading: const Icon(Icons.local_fire_department),
                title: const Text('En Uzun Seri'),
                trailing: Text('${s.longestStreak} gün'),
              ),
              ListTile(
                leading: const Icon(Icons.person_pin),
                title: const Text('En Çok Çalışılan Bölge'),
                trailing: Text(s.topBodyArea),
              ),

              // ── BÖLÜM 5: Rozetler ────────────────────────────────────
              _sectionHeader('Rozetler'),
              BadgesSection(earnedBadges: s.earnedBadges),

              // ── BÖLÜM 6: Paylaşım ────────────────────────────────────
              _sectionHeader('Paylaşım'),
              ListTile(
                leading: const Icon(Icons.ios_share),
                title: const Text('Başarımı Paylaş'),
                subtitle: const Text(
                  'Streak ve rozetlerini arkadaşlarınla paylaş',
                ),
                onTap: () => _shareAchievement(s),
              ),

              // ── BÖLÜM 7: Veri Dışa Aktarım ───────────────────────────
              _sectionHeader('Veri Dışa Aktarım'),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Verilerimi İndir'),
                subtitle:
                    const Text('Ağrı günlüğü ve egzersiz geçmişi (JSON)'),
                onTap: _exportData,
              ),

              // ── BÖLÜM 8: Fizyoterapist ───────────────────────────────
              _sectionHeader('Fizyoterapistim'),
              ListTile(
                leading: const Icon(Icons.medical_services),
                title: const Text('Fizyoterapiste Git'),
                subtitle: const Text('Fizyoterapist bağlantısını yönet'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(AppRoutes.marketplace),
              ),

              // ── BÖLÜM 9: Premium & Hesap ─────────────────────────────
              _sectionHeader('Premium & Abonelik'),
              ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: const Text('Abonelik Durumu'),
                subtitle: const Text('Ücretsiz Plan'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(AppRoutes.paywall),
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text('Satın Almaları Geri Yükle'),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Satın alma geri yükleme yakında eklenecek.',
                    ),
                  ),
                ),
              ),

              // ── BÖLÜM 10: Dil & Görünüm ──────────────────────────────
              _sectionHeader('Dil & Görünüm'),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Dil'),
                trailing: DropdownButton<String>(
                  value: ref.watch(localeProvider).languageCode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(localeProvider.notifier).setLocale(v);
                    }
                  },
                ),
              ),

              // ── BÖLÜM 11-12: Güvenlik & Hesap ───────────────────────
              SecurityLinksSection(
                onDeleteAccount: _deleteAccount,
                sectionHeader: _sectionHeader,
              ),
              const SizedBox(height: 40),
              // ── Footer ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 32, bottom: 16),
                child: Text(
                  'Made with ❤️ for N.A',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary.withValues(alpha: 0.35),
                    fontStyle: FontStyle.italic,
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
}
