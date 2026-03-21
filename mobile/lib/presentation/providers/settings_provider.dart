import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/badge_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/profile_service.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class SettingsState {
  // Profile fields
  final String age;
  final String height;
  final String weight;
  final String fitnessLevel;
  final List<String> injuries;

  // Notification fields
  final bool exerciseNotifEnabled;
  final TimeOfDay exerciseTime;
  final bool painLogNotifEnabled;
  final TimeOfDay painLogTime;

  // Goals
  final int weeklyGoal;

  // Stats
  final int totalExercises;
  final int longestStreak;
  final String topBodyArea;

  // Badges
  final Set<String> earnedBadges;

  // Status
  final bool loading;
  final String? loadError;

  const SettingsState({
    this.age = '',
    this.height = '',
    this.weight = '',
    this.fitnessLevel = 'beginner',
    this.injuries = const [],
    this.exerciseNotifEnabled = false,
    this.exerciseTime = const TimeOfDay(hour: 9, minute: 0),
    this.painLogNotifEnabled = false,
    this.painLogTime = const TimeOfDay(hour: 20, minute: 0),
    this.weeklyGoal = 3,
    this.totalExercises = 0,
    this.longestStreak = 0,
    this.topBodyArea = '-',
    this.earnedBadges = const {},
    this.loading = true,
    this.loadError,
  });

  SettingsState copyWith({
    String? age,
    String? height,
    String? weight,
    String? fitnessLevel,
    List<String>? injuries,
    bool? exerciseNotifEnabled,
    TimeOfDay? exerciseTime,
    bool? painLogNotifEnabled,
    TimeOfDay? painLogTime,
    int? weeklyGoal,
    int? totalExercises,
    int? longestStreak,
    String? topBodyArea,
    Set<String>? earnedBadges,
    bool? loading,
    String? loadError,
    bool clearLoadError = false,
  }) {
    return SettingsState(
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      injuries: injuries ?? this.injuries,
      exerciseNotifEnabled:
          exerciseNotifEnabled ?? this.exerciseNotifEnabled,
      exerciseTime: exerciseTime ?? this.exerciseTime,
      painLogNotifEnabled: painLogNotifEnabled ?? this.painLogNotifEnabled,
      painLogTime: painLogTime ?? this.painLogTime,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      totalExercises: totalExercises ?? this.totalExercises,
      longestStreak: longestStreak ?? this.longestStreak,
      topBodyArea: topBodyArea ?? this.topBodyArea,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      loading: loading ?? this.loading,
      loadError: clearLoadError ? null : (loadError ?? this.loadError),
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  static const Set<String> _validFitnessLevels = {
    'beginner',
    'intermediate',
    'advanced',
  };

  @override
  Future<SettingsState> build() async {
    return _load();
  }

  Future<SettingsState> _load() async {
    final profile = await ProfileService.loadProfile();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    Map<String, dynamic> settings = {};
    if (uid != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        settings = doc.data() ?? {};
      } catch (_) {
        // Firestore erişim hatası — varsayılan değerler kullan
      }
    }

    Set<String> earnedBadges = {};
    try {
      earnedBadges = await BadgeService.getEarnedBadgeIds();
    } catch (_) {
      // Rozet verisi alınamadı — boş set ile devam et
    }

    int totalExercises = 0;
    int longestStreak = 0;
    String topBodyArea = '-';

    if (uid != null) {
      try {
        final stats = await _loadStats(uid);
        totalExercises = stats.$1;
        longestStreak = stats.$2;
        topBodyArea = stats.$3;
      } catch (_) {
        // İstatistik verisi alınamadı — varsayılan sıfırlar kullan
      }
    }

    final notifSettings =
        await NotificationService.instance.getReminderSettings();

    return SettingsState(
      age: profile['age']?.toString() ?? '',
      height: profile['height']?.toString() ?? '',
      weight: profile['weight']?.toString() ?? '',
      fitnessLevel: _sanitizeFitnessLevel(profile['fitnessLevel']?.toString()),
      injuries: List<String>.from(profile['injuries'] as List? ?? []),
      weeklyGoal: (settings['weeklyGoal'] as int?) ?? 3,
      earnedBadges: earnedBadges,
      exerciseNotifEnabled: notifSettings.enabled,
      exerciseTime: TimeOfDay(
        hour: notifSettings.hour,
        minute: notifSettings.minute,
      ),
      painLogNotifEnabled: settings['painLogNotifEnabled'] as bool? ?? false,
      painLogTime: const TimeOfDay(hour: 20, minute: 0),
      totalExercises: totalExercises,
      longestStreak: longestStreak,
      topBodyArea: topBodyArea,
      loading: false,
      loadError: null,
    );
  }

  Future<(int, int, String)> _loadStats(String uid) async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('analyses')
        .orderBy('createdAt', descending: false)
        .get();

    final totalExercises = snap.docs.length;

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
    final longestStreak = maxStreak;

    // Top body area
    final areaCount = <String, int>{};
    for (final d in snap.docs) {
      final area = d.data()['bodyArea'] as String? ?? '';
      if (area.isNotEmpty) {
        areaCount[area] = (areaCount[area] ?? 0) + 1;
      }
    }
    String topBodyArea = '-';
    if (areaCount.isNotEmpty) {
      topBodyArea = areaCount.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }

    return (totalExercises, longestStreak, topBodyArea);
  }

  /// Re-load all settings (used by "Tekrar Dene" button).
  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> saveProfile(Map<String, dynamic> profileUpdates) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final profile = await ProfileService.loadProfile();
    profile['age'] =
        int.tryParse(profileUpdates['age']?.toString() ?? '') ??
            profile['age'];
    profile['height'] =
        int.tryParse(profileUpdates['height']?.toString() ?? '') ??
            profile['height'];
    profile['weight'] =
        int.tryParse(profileUpdates['weight']?.toString() ?? '') ??
            profile['weight'];
    profile['fitnessLevel'] = profileUpdates['fitnessLevel'] ?? current.fitnessLevel;
    profile['injuries'] = profileUpdates['injuries'] ?? current.injuries;
    await ProfileService.saveProfile(profile);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        'age': int.tryParse(profileUpdates['age']?.toString() ?? ''),
        'height': int.tryParse(profileUpdates['height']?.toString() ?? ''),
        'weight': int.tryParse(profileUpdates['weight']?.toString() ?? ''),
        'fitnessLevel':
            profileUpdates['fitnessLevel'] ?? current.fitnessLevel,
        'injuries': profileUpdates['injuries'] ?? current.injuries,
      }, SetOptions(merge: true));
    }

    state = AsyncData(current.copyWith(
      age: profileUpdates['age']?.toString() ?? current.age,
      height: profileUpdates['height']?.toString() ?? current.height,
      weight: profileUpdates['weight']?.toString() ?? current.weight,
      fitnessLevel:
          profileUpdates['fitnessLevel']?.toString() ?? current.fitnessLevel,
      injuries: profileUpdates['injuries'] != null
          ? List<String>.from(profileUpdates['injuries'] as List)
          : current.injuries,
    ));
  }

  Future<void> saveGoal(int weeklyGoal) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'weeklyGoal': weeklyGoal}, SetOptions(merge: true));

    state = AsyncData(current.copyWith(weeklyGoal: weeklyGoal));
  }

  Future<void> saveNotifSettings({
    required bool exerciseEnabled,
    required TimeOfDay exerciseTime,
    required bool painLogEnabled,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    if (exerciseEnabled) {
      await NotificationService.instance.requestPermission();
      await NotificationService.instance.scheduleDaily(
        exerciseTime.hour,
        exerciseTime.minute,
      );
    } else {
      await NotificationService.instance.cancel();
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        'painLogNotifEnabled': painLogEnabled,
      }, SetOptions(merge: true));
    }

    state = AsyncData(current.copyWith(
      exerciseNotifEnabled: exerciseEnabled,
      exerciseTime: exerciseTime,
      painLogNotifEnabled: painLogEnabled,
    ));
  }

  // ─── Local state mutations (no async save needed) ─────────────────────────

  void setFitnessLevel(String value) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(fitnessLevel: value));
  }

  void addInjury(String value) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
        current.copyWith(injuries: [...current.injuries, value]));
  }

  void removeInjury(String value) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
        injuries: current.injuries.where((i) => i != value).toList()));
  }

  void setWeeklyGoal(int value) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(weeklyGoal: value));
  }

  void setExerciseNotifEnabled(bool value) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(exerciseNotifEnabled: value));
  }

  void setExerciseTime(TimeOfDay value) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(exerciseTime: value));
  }

  void setPainLogNotifEnabled(bool value) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(painLogNotifEnabled: value));
  }

  void setPainLogTime(TimeOfDay value) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(painLogTime: value));
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static String _sanitizeFitnessLevel(String? raw) {
    if (raw != null && _validFitnessLevels.contains(raw)) return raw;
    return 'beginner';
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
