import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String senderId;

  /// النص
  final String text;

  /// 🖼️ صورة
  final String? imageUrl;

  /// 🎤 صوت
  final String? audioUrl;

  /// ✔ seen
  final bool isRead;

  /// ⌨️ typing (❌ مش لازم يتخزن في message)
  final bool isTyping;

  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.imageUrl,
    this.audioUrl,
    this.isRead = false,
    this.isTyping = false,
  });

  /// ================= FROM FIREBASE =================
  factory ChatMessageModel.fromJson(
      Map<String, dynamic> json,
      String docId,
      ) {
    return ChatMessageModel(
      id: docId,
      senderId: json['senderId'] ?? '',
      text: json['text'] ?? '',

      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,

      isRead: json['isRead'] ?? false,

      /// ⚠️ مهم: غالبًا مش هنستخدمها من message doc
      isTyping: json['isTyping'] ?? false,

      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  /// ================= TO FIREBASE =================
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'text': text,

      'imageUrl': imageUrl,
      'audioUrl': audioUrl,

      'isRead': isRead,

      /// ❌ الأفضل: مايتسجلش في messages
      /// لكن سيبته optional لو انت مستخدمه
      'isTyping': isTyping,

      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// ================= HELPERS =================

  bool get isText => text.isNotEmpty && imageUrl == null && audioUrl == null;

  bool get isImage => imageUrl != null && imageUrl!.isNotEmpty;

  bool get isAudio => audioUrl != null && audioUrl!.isNotEmpty;
}