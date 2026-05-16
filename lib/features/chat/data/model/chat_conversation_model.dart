import 'package:cloud_firestore/cloud_firestore.dart';

class ChatConversationModel {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String> participantImages;
  final String lastMessage;
  final DateTime lastMessageAt;
  final String lastSenderId;

  ChatConversationModel({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantImages,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.lastSenderId,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json, String docId) {
    return ChatConversationModel(
      id: docId,
      participantIds: List<String>.from(json['participantIds'] ?? []),
      participantNames: Map<String, String>.from(json['participantNames'] ?? {}),
      participantImages: Map<String, String>.from(json['participantImages'] ?? {}),
      lastMessage: json['lastMessage'] ?? '',
      lastMessageAt: (json['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSenderId: json['lastSenderId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'participantIds': participantIds,
    'participantNames': participantNames,
    'participantImages': participantImages,
    'lastMessage': lastMessage,
    'lastMessageAt': Timestamp.fromDate(lastMessageAt),
    'lastSenderId': lastSenderId,
  };

  /// ID الدردشة = الـ IDs مرتبة عشان يكون ثابت لأي اتجاه
  static String buildChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }
}