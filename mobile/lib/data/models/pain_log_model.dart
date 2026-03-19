import 'package:cloud_firestore/cloud_firestore.dart';

class PainLogModel {
  final String date; // YYYY-MM-DD
  final int score; // 1-10
  final DateTime createdAt;

  const PainLogModel({
    required this.date,
    required this.score,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'date': date,
        'score': score,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory PainLogModel.fromMap(String date, Map<String, dynamic> map) {
    final ts = map['createdAt'];
    return PainLogModel(
      date: date,
      score: (map['score'] as num).toInt().clamp(1, 10),
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }
}
