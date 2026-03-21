import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BadgeDefinition {
  final String id;
  final String name;
  final String description;
  final String icon; // emoji

  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

class BadgeService {
  static const List<BadgeDefinition> allBadges = [
    BadgeDefinition(
      id: 'first_step',
      name: 'İlk Adım',
      description: 'İlk egzersizini tamamla',
      icon: '🥇',
    ),
    BadgeDefinition(
      id: 'streak_3',
      name: '3 Günlük Seri',
      description: '3 gün üst üste egzersiz yap',
      icon: '🔥',
    ),
    BadgeDefinition(
      id: 'streak_7',
      name: '7 Günlük Seri',
      description: '7 gün üst üste egzersiz yap',
      icon: '⚡',
    ),
    BadgeDefinition(
      id: 'streak_30',
      name: '30 Günlük Seri',
      description: '30 gün üst üste egzersiz yap',
      icon: '💎',
    ),
    BadgeDefinition(
      id: 'pain_hunter',
      name: 'Ağrı Avcısı',
      description: '10 analiz tamamla',
      icon: '🎯',
    ),
    BadgeDefinition(
      id: 'body_mapper',
      name: 'Vücut Haritacısı',
      description: '5 farklı bölge analiz et',
      icon: '🗺️',
    ),
    BadgeDefinition(
      id: 'quick_start',
      name: 'Hızlı Başlangıç',
      description: 'İlk hızlı egzersizi tamamla',
      icon: '⚡',
    ),
    BadgeDefinition(
      id: 'regular_user',
      name: 'Düzenli Kullanıcı',
      description: '7 gün üst üste giriş yap',
      icon: '📅',
    ),
  ];

  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static Future<Set<String>> getEarnedBadgeIds() async {
    final uid = _uid;
    if (uid == null) return {};
    final snap =
        await _db.collection('users').doc(uid).collection('badges').get();
    return snap.docs.map((d) => d.id).toSet();
  }

  static Future<void> _awardBadge(String badgeId) async {
    final uid = _uid;
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('badges')
        .doc(badgeId)
        .set({'earnedAt': FieldValue.serverTimestamp()});
  }

  static Future<void> checkAndAwardBadges() async {
    final uid = _uid;
    if (uid == null) return;
    final earned = await getEarnedBadgeIds();

    // Get history for checks
    final historySnap = await _db
        .collection('users')
        .doc(uid)
        .collection('analyses')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    final analyses = historySnap.docs;

    // first_step
    if (!earned.contains('first_step') && analyses.isNotEmpty) {
      await _awardBadge('first_step');
    }

    // pain_hunter — 10 analyses
    if (!earned.contains('pain_hunter') && analyses.length >= 10) {
      await _awardBadge('pain_hunter');
    }

    // body_mapper — 5 different body areas
    if (!earned.contains('body_mapper')) {
      final areas = analyses
          .map((d) => d.data()['bodyArea'] as String? ?? '')
          .toSet();
      if (areas.length >= 5) await _awardBadge('body_mapper');
    }

    // Streak badges — check consecutive days
    if (analyses.isNotEmpty) {
      final dates = analyses
          .map((d) {
            final ts = d.data()['createdAt'];
            if (ts is Timestamp) return ts.toDate();
            return null;
          })
          .whereType<DateTime>()
          .map((d) => DateTime(d.year, d.month, d.day))
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a));

      int streak = 0;
      if (dates.isNotEmpty) {
        streak = 1;
        for (int i = 1; i < dates.length; i++) {
          if (dates[i - 1].difference(dates[i]).inDays == 1) {
            streak++;
          } else {
            break;
          }
        }
      }

      if (!earned.contains('streak_3') && streak >= 3) {
        await _awardBadge('streak_3');
      }
      if (!earned.contains('streak_7') && streak >= 7) {
        await _awardBadge('streak_7');
      }
      if (!earned.contains('streak_30') && streak >= 30) {
        await _awardBadge('streak_30');
      }
    }
  }
}
