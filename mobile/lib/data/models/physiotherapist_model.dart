import 'package:cloud_firestore/cloud_firestore.dart';

// Approval status values
class PtStatus {
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
}

class PhysiotherapistModel {
  final String uid;
  final String name;
  final String title; // e.g. 'Fizyoterapist', 'Uzman Fizyoterapist'
  final String bio;
  final List<String> specializations; // e.g. ['Bel ağrısı', 'Spor yaralanmaları']
  final int yearsExperience;
  final String city;
  final String diplomaInstitution;
  final String status; // pending | approved | rejected
  final double rating;
  final int reviewCount;
  final DateTime createdAt;

  const PhysiotherapistModel({
    required this.uid,
    required this.name,
    required this.title,
    required this.bio,
    required this.specializations,
    required this.yearsExperience,
    required this.city,
    required this.diplomaInstitution,
    this.status = PtStatus.pending,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
  });

  bool get isApproved => status == PtStatus.approved;
  bool get isPending => status == PtStatus.pending;

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'title': title,
        'bio': bio,
        'specializations': specializations,
        'yearsExperience': yearsExperience,
        'city': city,
        'diplomaInstitution': diplomaInstitution,
        'status': status,
        'rating': rating,
        'reviewCount': reviewCount,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory PhysiotherapistModel.fromMap(String uid, Map<String, dynamic> m) {
    final ts = m['createdAt'];
    return PhysiotherapistModel(
      uid: uid,
      name: m['name'] as String? ?? '',
      title: m['title'] as String? ?? 'Fizyoterapist',
      bio: m['bio'] as String? ?? '',
      specializations:
          List<String>.from(m['specializations'] as List? ?? []),
      yearsExperience: (m['yearsExperience'] as num?)?.toInt() ?? 0,
      city: m['city'] as String? ?? '',
      diplomaInstitution: m['diplomaInstitution'] as String? ?? '',
      status: m['status'] as String? ?? PtStatus.pending,
      rating: (m['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (m['reviewCount'] as num?)?.toInt() ?? 0,
      createdAt: ts is Timestamp
          ? ts.toDate()
          : DateTime.tryParse(ts?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
