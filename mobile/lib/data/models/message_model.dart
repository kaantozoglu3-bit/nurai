import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'content': content,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory MessageModel.fromMap(String id, Map<String, dynamic> m) {
    final ts = m['createdAt'];
    return MessageModel(
      id: id,
      senderId: m['senderId'] as String? ?? '',
      content: m['content'] as String? ?? '',
      createdAt: ts is Timestamp
          ? ts.toDate()
          : DateTime.tryParse(ts?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class ConversationModel {
  final String id;
  final String ptId;
  final String userId;
  final String ptName;
  final String userName;
  final String lastMessage;
  final DateTime lastMessageAt;

  const ConversationModel({
    required this.id,
    required this.ptId,
    required this.userId,
    required this.ptName,
    required this.userName,
    this.lastMessage = '',
    required this.lastMessageAt,
  });

  Map<String, dynamic> toMap() => {
        'ptId': ptId,
        'userId': userId,
        'ptName': ptName,
        'userName': userName,
        'lastMessage': lastMessage,
        'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      };

  factory ConversationModel.fromMap(String id, Map<String, dynamic> m) {
    final ts = m['lastMessageAt'];
    return ConversationModel(
      id: id,
      ptId: m['ptId'] as String? ?? '',
      userId: m['userId'] as String? ?? '',
      ptName: m['ptName'] as String? ?? '',
      userName: m['userName'] as String? ?? '',
      lastMessage: m['lastMessage'] as String? ?? '',
      lastMessageAt: ts is Timestamp
          ? ts.toDate()
          : DateTime.tryParse(ts?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
