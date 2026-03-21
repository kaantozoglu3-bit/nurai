import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/services/notification_service.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  ({bool enabled, int hour, int minute})? _exercisePrefs;
  bool _painEnabled = false;
  int _painHour = 20;
  int _painMinute = 0;
  bool _loading = true;
  bool _exerciseLoading = false;
  bool _painLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final exercise = await NotificationService.instance.getReminderSettings();
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _exercisePrefs = exercise;
        _painEnabled = prefs.getBool('pain_notif_enabled') ?? false;
        _painHour = prefs.getInt('pain_notif_hour') ?? 20;
        _painMinute = prefs.getInt('pain_notif_minute') ?? 0;
        _loading = false;
      });
    }
  }

  Future<void> _toggleExercise(bool enabled) async {
    setState(() => _exerciseLoading = true);
    try {
      if (enabled) {
        final granted =
            await NotificationService.instance.requestPermission();
        if (!granted && mounted) {
          _showPermissionDenied();
          return;
        }
        final prefs = _exercisePrefs;
        await NotificationService.instance.scheduleDaily(
          prefs?.hour ?? 9,
          prefs?.minute ?? 0,
        );
      } else {
        await NotificationService.instance.cancel();
      }
      await _loadPrefs();
    } catch (e) {
      if (mounted) _showError('Bildirim ayarlanamadı. Tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _exerciseLoading = false);
    }
  }

  Future<void> _pickExerciseTime() async {
    final prefs = _exercisePrefs;
    if (prefs == null) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: prefs.hour, minute: prefs.minute),
    );
    if (picked == null || !mounted) return;
    setState(() => _exerciseLoading = true);
    try {
      if (prefs.enabled) {
        await NotificationService.instance
            .scheduleDaily(picked.hour, picked.minute);
      } else {
        final sp = await SharedPreferences.getInstance();
        await sp.setInt('exercise_reminder_hour', picked.hour);
        await sp.setInt('exercise_reminder_minute', picked.minute);
      }
      await _loadPrefs();
    } catch (e) {
      if (mounted) _showError('Saat kaydedilemedi. Tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _exerciseLoading = false);
    }
  }

  Future<void> _togglePain(bool enabled) async {
    setState(() => _painLoading = true);
    try {
      if (enabled) {
        final granted =
            await NotificationService.instance.requestPermission();
        if (!granted && mounted) {
          _showPermissionDenied();
          return;
        }
      }
      final sp = await SharedPreferences.getInstance();
      await sp.setBool('pain_notif_enabled', enabled);
      await _loadPrefs();
    } catch (e) {
      if (mounted) _showError('Bildirim ayarlanamadı. Tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _painLoading = false);
    }
  }

  Future<void> _pickPainTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _painHour, minute: _painMinute),
    );
    if (picked == null || !mounted) return;
    setState(() => _painLoading = true);
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setInt('pain_notif_hour', picked.hour);
      await sp.setInt('pain_notif_minute', picked.minute);
      await _loadPrefs();
    } catch (e) {
      if (mounted) _showError('Saat kaydedilemedi. Tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _painLoading = false);
    }
  }

  void _showPermissionDenied() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bildirim izni verilmedi. Ayarlardan etkinleştirin.'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  String _formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Bildirim Ayarları',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Bildirimler yalnızca Android ve iOS cihazlarda desteklenmektedir.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    final exercise = _exercisePrefs!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Egzersiz Hatırlatıcısı ────────────────────────────────────────
        _SectionHeader(title: 'Egzersiz Hatırlatıcısı'),
        const SizedBox(height: 8),
        Card(
          color: AppColors.surface,
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text(
                  'Günlük egzersiz hatırlatıcısı',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Her gün belirlediğin saatte hatırlatma gönderir',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary),
                ),
                value: exercise.enabled,
                onChanged: _exerciseLoading ? null : _toggleExercise,
                activeThumbColor: AppColors.primary,
                secondary: _exerciseLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child:
                            CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.fitness_center_outlined,
                        color: AppColors.primary),
              ),
              if (exercise.enabled) ...[
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading:
                      const Icon(Icons.access_time, color: AppColors.primary),
                  title: const Text(
                    'Hatırlatma saati',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 14),
                  ),
                  trailing: Text(
                    _formatTime(exercise.hour, exercise.minute),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  onTap: _pickExerciseTime,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Ağrı Günlüğü Hatırlatıcısı ────────────────────────────────────
        _SectionHeader(title: 'Ağrı Günlüğü Hatırlatıcısı'),
        const SizedBox(height: 8),
        Card(
          color: AppColors.surface,
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text(
                  'Günlük ağrı günlüğü hatırlatıcısı',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Ağrı seviyeni kaydetmeni hatırlatır',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary),
                ),
                value: _painEnabled,
                onChanged: _painLoading ? null : _togglePain,
                activeThumbColor: AppColors.primary,
                secondary: _painLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child:
                            CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.bar_chart_outlined,
                        color: AppColors.primary),
              ),
              if (_painEnabled) ...[
                const Divider(height: 1, color: AppColors.border),
                ListTile(
                  leading:
                      const Icon(Icons.access_time, color: AppColors.primary),
                  title: const Text(
                    'Hatırlatma saati',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 14),
                  ),
                  trailing: Text(
                    _formatTime(_painHour, _painMinute),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  onTap: _pickPainTime,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Info ───────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bildirimler sistem ayarlarından kapatılabilir. Pil optimizasyonu kapalıysa daha güvenilir çalışır.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.primary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}
