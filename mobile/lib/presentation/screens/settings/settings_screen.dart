import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/services/badge_service.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/profile_service.dart';
import '../../providers/locale_provider.dart';
import '../../../core/router/app_router.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Profile fields
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String _fitnessLevel = 'beginner';
  List<String> _injuries = [];

  // Notification fields
  bool _exerciseNotifEnabled = false;
  TimeOfDay _exerciseTime = const TimeOfDay(hour: 9, minute: 0);
  bool _painLogNotifEnabled = false;
  TimeOfDay _painLogTime = const TimeOfDay(hour: 20, minute: 0);

  // Goals
  int _weeklyGoal = 3;

  // Stats
  int _totalExercises = 0;
  int _longestStreak = 0;
  String _topBodyArea = '-';

  // Badges
  Set<String> _earnedBadges = {};

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final profile = await ProfileService.loadProfile();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    Map<String, dynamic> settings = {};
    if (uid != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      settings = doc.data() ?? {};
    }

    _earnedBadges = await BadgeService.getEarnedBadgeIds();
    await _loadStats(uid);

    // Load notification settings
    final notifSettings =
        await NotificationService.instance.getReminderSettings();

    if (mounted) {
      setState(() {
        _ageCtrl.text = profile['age']?.toString() ?? '';
        _heightCtrl.text = profile['height']?.toString() ?? '';
        _weightCtrl.text = profile['weight']?.toString() ?? '';
        _fitnessLevel =
            profile['fitnessLevel']?.toString() ?? 'beginner';
        _injuries =
            List<String>.from(profile['injuries'] as List? ?? []);
        _weeklyGoal = (settings['weeklyGoal'] as int?) ?? 3;
        _exerciseNotifEnabled = notifSettings.enabled;
        _exerciseTime = TimeOfDay(
          hour: notifSettings.hour,
          minute: notifSettings.minute,
        );
        _painLogNotifEnabled =
            settings['painLogNotifEnabled'] as bool? ?? false;
        _loading = false;
      });
    }
  }

  Future<void> _loadStats(String? uid) async {
    if (uid == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('analyses')
        .orderBy('createdAt', descending: false)
        .get();

    _totalExercises = snap.docs.length;

    // Streak calculation
    final dates = snap.docs
        .map((d) {
          final ts = d.data()['createdAt'];
          if (ts is Timestamp) return ts.toDate();
          return null;
        })
        .whereType<DateTime>()
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort();

    int maxStreak = 0, cur = 0;
    for (int i = 0; i < dates.length; i++) {
      if (i == 0 || dates[i].difference(dates[i - 1]).inDays == 1) {
        cur++;
        if (cur > maxStreak) maxStreak = cur;
      } else {
        cur = 1;
      }
    }
    _longestStreak = maxStreak;

    // Top body area
    final areaCount = <String, int>{};
    for (final d in snap.docs) {
      final area = d.data()['bodyArea'] as String? ?? '';
      if (area.isNotEmpty) {
        areaCount[area] = (areaCount[area] ?? 0) + 1;
      }
    }
    if (areaCount.isNotEmpty) {
      _topBodyArea = areaCount.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }
  }

  Future<void> _saveProfile() async {
    final profile = await ProfileService.loadProfile();
    profile['age'] = int.tryParse(_ageCtrl.text) ?? profile['age'];
    profile['height'] =
        int.tryParse(_heightCtrl.text) ?? profile['height'];
    profile['weight'] =
        int.tryParse(_weightCtrl.text) ?? profile['weight'];
    profile['fitnessLevel'] = _fitnessLevel;
    profile['injuries'] = _injuries;
    await ProfileService.saveProfile(profile);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        'age': int.tryParse(_ageCtrl.text),
        'height': int.tryParse(_heightCtrl.text),
        'weight': int.tryParse(_weightCtrl.text),
        'fitnessLevel': _fitnessLevel,
        'injuries': _injuries,
      }, SetOptions(merge: true));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil kaydedildi')),
      );
    }
  }

  Future<void> _saveGoal() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'weeklyGoal': _weeklyGoal}, SetOptions(merge: true));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hedef kaydedildi')),
      );
    }
  }

  Future<void> _saveNotifSettings() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (_exerciseNotifEnabled) {
      await NotificationService.instance.requestPermission();
      await NotificationService.instance.scheduleDaily(
        _exerciseTime.hour,
        _exerciseTime.minute,
      );
    } else {
      await NotificationService.instance.cancel();
    }

    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        'painLogNotifEnabled': _painLogNotifEnabled,
      }, SetOptions(merge: true));
    }

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
      builder: (ctx) => AlertDialog(
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

  void _shareAchievement() {
    final earnedNames = BadgeService.allBadges
        .where((b) => _earnedBadges.contains(b.id))
        .map((b) => '${b.icon} ${b.name}')
        .join('\n');

    Share.share(
      'Nurai ile $_totalExercises egzersiz tamamladım! 🏆\n'
      'En uzun seri: $_longestStreak gün\n\n'
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
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          // ── BÖLÜM 1: Profil Düzenleme ────────────────────────────
          _sectionHeader('Profil Düzenleme'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ageCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Yaş',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _heightCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Boy (cm)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _weightCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Kilo (kg)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _fitnessLevel,
                  decoration: const InputDecoration(
                    labelText: 'Fitness Seviyesi',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'beginner',
                      child: Text('Başlangıç'),
                    ),
                    DropdownMenuItem(
                      value: 'intermediate',
                      child: Text('Orta'),
                    ),
                    DropdownMenuItem(
                      value: 'advanced',
                      child: Text('İleri'),
                    ),
                  ],
                  onChanged: (v) =>
                      setState(() => _fitnessLevel = v ?? 'beginner'),
                ),
                const SizedBox(height: 12),
                // Injuries chip list
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    children: [
                      ..._injuries.map(
                        (inj) => Chip(
                          label: Text(inj),
                          onDeleted: () =>
                              setState(() => _injuries.remove(inj)),
                        ),
                      ),
                      ActionChip(
                        label: const Text('+ Ekle'),
                        onPressed: () async {
                          final ctrl = TextEditingController();
                          final result = await showDialog<String>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Sakatlık/Rahatsızlık Ekle'),
                              content: TextField(
                                controller: ctrl,
                                decoration: const InputDecoration(
                                  hintText: 'örn: Bel fıtığı',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('İptal'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, ctrl.text),
                                  child: const Text('Ekle'),
                                ),
                              ],
                            ),
                          );
                          if (result != null && result.trim().isNotEmpty) {
                            setState(() => _injuries.add(result.trim()));
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Profili Kaydet'),
                  ),
                ),
              ],
            ),
          ),

          // ── BÖLÜM 2: Bildirimler ─────────────────────────────────
          _sectionHeader('Bildirimler'),
          SwitchListTile(
            title: const Text('Egzersiz Hatırlatıcısı'),
            value: _exerciseNotifEnabled,
            onChanged: (v) => setState(() => _exerciseNotifEnabled = v),
          ),
          if (_exerciseNotifEnabled)
            ListTile(
              title: const Text('Egzersiz Saati'),
              trailing: Text(_exerciseTime.format(context)),
              onTap: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: _exerciseTime,
                );
                if (t != null) setState(() => _exerciseTime = t);
              },
            ),
          SwitchListTile(
            title: const Text('Ağrı Günlüğü Hatırlatması'),
            value: _painLogNotifEnabled,
            onChanged: (v) => setState(() => _painLogNotifEnabled = v),
          ),
          if (_painLogNotifEnabled)
            ListTile(
              title: const Text('Günlük Kayıt Saati'),
              trailing: Text(_painLogTime.format(context)),
              onTap: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: _painLogTime,
                );
                if (t != null) setState(() => _painLogTime = t);
              },
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveNotifSettings,
                child: const Text('Bildirimleri Kaydet'),
              ),
            ),
          ),

          // ── BÖLÜM 3: Hedefler ────────────────────────────────────
          _sectionHeader('Hedefler'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Haftalık Egzersiz Hedefi: $_weeklyGoal gün'),
                Slider(
                  value: _weeklyGoal.toDouble(),
                  min: 1,
                  max: 7,
                  divisions: 6,
                  label: '$_weeklyGoal gün',
                  onChanged: (v) =>
                      setState(() => _weeklyGoal = v.round()),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveGoal,
                    child: const Text('Hedefi Kaydet'),
                  ),
                ),
              ],
            ),
          ),

          // ── BÖLÜM 4: İlerleme Özeti ──────────────────────────────
          _sectionHeader('İlerleme Özeti'),
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Toplam Egzersiz'),
            trailing: Text('$_totalExercises'),
          ),
          ListTile(
            leading: const Icon(Icons.local_fire_department),
            title: const Text('En Uzun Seri'),
            trailing: Text('$_longestStreak gün'),
          ),
          ListTile(
            leading: const Icon(Icons.person_pin),
            title: const Text('En Çok Çalışılan Bölge'),
            trailing: Text(_topBodyArea),
          ),

          // ── BÖLÜM 5: Rozetler ────────────────────────────────────
          _sectionHeader('Rozetler'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: BadgeService.allBadges.length,
              itemBuilder: (ctx, i) {
                final badge = BadgeService.allBadges[i];
                final earned = _earnedBadges.contains(badge.id);
                return Tooltip(
                  message: badge.description,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        badge.icon,
                        style: TextStyle(
                          fontSize: 28,
                          color: earned ? null : Colors.grey,
                        ),
                      ),
                      Text(
                        badge.name,
                        style: TextStyle(
                          fontSize: 9,
                          color: earned ? null : Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ── BÖLÜM 6: Paylaşım ────────────────────────────────────
          _sectionHeader('Paylaşım'),
          ListTile(
            leading: const Icon(Icons.ios_share),
            title: const Text('Başarımı Paylaş'),
            subtitle: const Text(
              'Streak ve rozetlerini arkadaşlarınla paylaş',
            ),
            onTap: _shareAchievement,
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

          // ── BÖLÜM 11: Güvenlik & Gizlilik ────────────────────────
          _sectionHeader('Güvenlik & Gizlilik'),
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text('Şifre Değiştir'),
            onTap: () async {
              final email =
                  FirebaseAuth.instance.currentUser?.email;
              if (email != null) {
                final messenger = ScaffoldMessenger.of(context);
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: email);
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Şifre sıfırlama e-postası $email adresine gönderildi.',
                      ),
                    ),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Gizlilik Politikası'),
            onTap: () =>
                launchUrl(Uri.parse('https://nurai.app/privacy')),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Kullanım Şartları'),
            onTap: () =>
                launchUrl(Uri.parse('https://nurai.app/terms')),
          ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('Destek / Geri Bildirim'),
            onTap: () => launchUrl(
              Uri.parse(
                'mailto:destek@nurai.app?subject=Nurai Destek',
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Hata Bildir'),
            onTap: () => launchUrl(
              Uri.parse(
                'mailto:destek@nurai.app?subject=Hata Bildirimi',
              ),
            ),
          ),

          // ── BÖLÜM 12: Hesap Sil ──────────────────────────────────
          _sectionHeader('Hesap'),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Hesabı Sil',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Tüm verileriniz kalıcı olarak silinir'),
            onTap: _deleteAccount,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }
}
