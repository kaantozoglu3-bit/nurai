import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../../core/constants/firestore_paths.dart';
import '../models/physiotherapist_model.dart';
import '../models/message_model.dart';

/// Result type for a single page of PT results.
class PtPage {
  final List<PhysiotherapistModel> pts;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final bool hasMore;

  const PtPage({
    required this.pts,
    required this.lastDocument,
    required this.hasMore,
  });
}

class MarketplaceService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ─── PT Profile ─────────────────────────────────────────────────────────────

  /// Saves current user as a physiotherapist (pending status by default).
  static Future<void> registerAsPhysiotherapist(
      PhysiotherapistModel pt) async {
    await _db.doc(FirestorePaths.physiotherapist(pt.uid)).set(pt.toMap());
  }

  /// Returns the PT profile for the current user (null if not a PT).
  static Future<PhysiotherapistModel?> getMyPtProfile() async {
    final uid = _uid;
    if (uid == null) return null;
    try {
      final snap =
          await _db.doc(FirestorePaths.physiotherapist(uid)).get();
      if (!snap.exists || snap.data() == null) return null;
      return PhysiotherapistModel.fromMap(snap.id, snap.data()!);
    } catch (e) {
      debugPrint('[Marketplace] getMyPtProfile error: $e');
      return null;
    }
  }

  static const int _kPageSize = 20;

  /// Returns the first page of approved physiotherapists.
  static Future<PtPage> getApprovedPts({
    String? city,
    String? specialization,
  }) async {
    return _fetchPage(city: city, specialization: specialization);
  }

  /// Loads the next page after [lastDocument].
  static Future<PtPage> getApprovedPtsNextPage({
    required DocumentSnapshot<Map<String, dynamic>> lastDocument,
    String? city,
    String? specialization,
  }) async {
    return _fetchPage(
      city: city,
      specialization: specialization,
      startAfter: lastDocument,
    );
  }

  static Future<PtPage> _fetchPage({
    String? city,
    String? specialization,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _db
          .collection(FirestorePaths.physiotherapists)
          .where('status', isEqualTo: PtStatus.approved)
          .orderBy('rating', descending: true)
          .limit(_kPageSize);

      if (city != null && city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
      }
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snap = await query.get();
      final pts = snap.docs
          .map((d) => PhysiotherapistModel.fromMap(d.id, d.data()))
          .toList();

      // Client-side specialization filter (Firestore array-contains limits)
      final filtered = (specialization != null && specialization.isNotEmpty)
          ? pts.where((pt) => pt.specializations.contains(specialization)).toList()
          : pts;

      return PtPage(
        pts: filtered,
        lastDocument: snap.docs.isNotEmpty
            ? snap.docs.last as DocumentSnapshot<Map<String, dynamic>>
            : null,
        hasMore: snap.docs.length == _kPageSize,
      );
    } catch (e) {
      debugPrint('[Marketplace] getApprovedPts error: $e');
      return const PtPage(pts: [], lastDocument: null, hasMore: false);
    }
  }

  // ─── Conversations ───────────────────────────────────────────────────────────

  /// Opens (or creates) a conversation between current user and a PT.
  static Future<String> openConversation({
    required String ptId,
    required String ptName,
    required String userName,
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('User not authenticated');

    // Deterministic conversation ID: sort UIDs to ensure uniqueness
    final ids = [uid, ptId]..sort();
    final convId = '${ids[0]}_${ids[1]}';

    final docRef = _db.doc(FirestorePaths.conversation(convId));
    final snap = await docRef.get();
    if (!snap.exists) {
      await docRef.set(ConversationModel(
        id: convId,
        ptId: ptId,
        userId: uid,
        ptName: ptName,
        userName: userName,
        lastMessageAt: DateTime.now(),
      ).toMap());
    }
    return convId;
  }

  /// Sends a message in a conversation.
  static Future<void> sendMessage(String convId, String content) async {
    final uid = _uid;
    if (uid == null) throw StateError('User not authenticated');

    final now = DateTime.now();
    final msgRef = _db
        .collection(FirestorePaths.messages(convId))
        .doc();

    final batch = _db.batch();
    batch.set(
        msgRef,
        MessageModel(
          id: msgRef.id,
          senderId: uid,
          content: content,
          createdAt: now,
        ).toMap());
    batch.update(_db.doc(FirestorePaths.conversation(convId)), {
      'lastMessage': content.length > 80 ? '${content.substring(0, 80)}…' : content,
      'lastMessageAt': Timestamp.fromDate(now),
    });
    await batch.commit();
  }

  /// Streams messages in a conversation (real-time).
  static Stream<List<MessageModel>> messagesStream(String convId) {
    return _db
        .collection(FirestorePaths.messages(convId))
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MessageModel.fromMap(d.id, d.data()))
            .toList());
  }

  /// Returns conversations for the current user (as a PT or as a user).
  static Future<List<ConversationModel>> getMyConversations() async {
    final uid = _uid;
    if (uid == null) return [];

    try {
      // Conversations where I'm the PT or the user
      final ptSnap = await _db
          .collection(FirestorePaths.conversations)
          .where('ptId', isEqualTo: uid)
          .orderBy('lastMessageAt', descending: true)
          .get();
      final userSnap = await _db
          .collection(FirestorePaths.conversations)
          .where('userId', isEqualTo: uid)
          .orderBy('lastMessageAt', descending: true)
          .get();

      final all = <String, ConversationModel>{};
      for (final d in [...ptSnap.docs, ...userSnap.docs]) {
        all[d.id] = ConversationModel.fromMap(d.id, d.data());
      }
      final list = all.values.toList()
        ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
      return list;
    } catch (e) {
      debugPrint('[Marketplace] getMyConversations error: $e');
      return [];
    }
  }
}
