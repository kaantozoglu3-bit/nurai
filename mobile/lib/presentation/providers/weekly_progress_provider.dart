import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final weeklyProgressProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return {'done': 0, 'goal': 3};

  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final weekStartDate =
      DateTime(weekStart.year, weekStart.month, weekStart.day);

  final snap = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('analyses')
      .where(
        'createdAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(weekStartDate),
      )
      .get();

  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();
  final goal = (userDoc.data()?['weeklyGoal'] as int?) ?? 3;

  return {'done': snap.docs.length, 'goal': goal};
});
