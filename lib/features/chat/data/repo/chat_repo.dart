import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../model/chat_conversation_model.dart';
import '../model/chat_message_model.dart';

class ChatRepo {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// ================= GET MESSAGES =================
  Stream<List<ChatMessageModel>> getMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => ChatMessageModel.fromJson(d.data(), d.id))
        .toList());
  }

  /// ================= TEXT MESSAGE =================
  Future<void> sendTextMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String senderImage,
    required String receiverId,
    required String receiverName,
    required String receiverImage,
    required String text,
  }) async {
    final msg = ChatMessageModel(
      id: '',
      senderId: senderId,
      text: text,
      createdAt: DateTime.now(),
    );

    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(msg.toJson());

    await _updateConversation(
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderImage: senderImage,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverImage: receiverImage,
      lastMessage: text,
    );
  }

  /// ================= IMAGE MESSAGE =================
  Future<void> sendImageMessage({
    required String chatId,
    required File file,
    required String senderId,
    required String senderName,
    required String senderImage,
    required String receiverId,
    required String receiverName,
    required String receiverImage,
  }) async {
    final ref = _storage.ref().child(
        'chat_images/$chatId/${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    final msg = ChatMessageModel(
      id: '',
      senderId: senderId,
      text: '',
      imageUrl: url,
      createdAt: DateTime.now(),
    );

    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(msg.toJson());

    await _updateConversation(
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderImage: senderImage,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverImage: receiverImage,
      lastMessage: '📷 صورة',
    );
  }

  /// ================= UPDATE CONVERSATION (FIXED IMPORTANT) =================
  Future<void> _updateConversation({
    required String chatId,
    required String senderId,
    required String senderName,
    required String senderImage,
    required String receiverId,
    required String receiverName,
    required String receiverImage,
    required String lastMessage,
  }) async {
    await _db.collection('chats').doc(chatId).set({
      'participantIds': [senderId, receiverId],

      'participantNames': {
        senderId: senderName,
        receiverId: receiverName,
      },

      'participantImages': {
        senderId: senderImage,
        receiverId: receiverImage,
      },

      'lastMessage': lastMessage,

      /// 🔥 مهم جدًا عشان الترتيب يشتغل
      'lastMessageAt': FieldValue.serverTimestamp(),

      'lastSenderId': senderId,
    }, SetOptions(merge: true));
  }

  /// ================= CONVERSATIONS STREAM (FIXED) =================
  Stream<List<ChatConversationModel>> getConversations(String uid) {
    return _db
        .collection('chats')
        .where('participantIds', arrayContains: uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) {
        return ChatConversationModel.fromJson(d.data(), d.id);
      }).toList();

      /// 🔥 حماية لو timestamp null
      list.sort((a, b) {
        return b.lastMessageAt.compareTo(a.lastMessageAt);
      });

      return list;
    });
  }

  /// ================= TYPING =================
  Future<void> setTyping({
    required String chatId,
    required String userId,
    required bool isTyping,
  }) async {
    await _db.collection('chats').doc(chatId).set({
      'typing_$userId': isTyping,
    }, SetOptions(merge: true));
  }

  Stream<bool> getTyping({
    required String chatId,
    required String otherUserId,
  }) {
    return _db.collection('chats').doc(chatId).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return false;
      return data['typing_$otherUserId'] ?? false;
    });
  }

  /// ================= READ MESSAGES =================
  Future<void> markMessagesAsRead(String chatId, String myUid) async {
    final unread = await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in unread.docs) {
      if (doc['senderId'] != myUid) {
        await doc.reference.update({'isRead': true});
      }
    }
  }


  Future<void> sendBookingRequest({
    required String myUid,
    required String myName,
    required String ownerId,
    required String propertyTitle,
  }) async {
    final chatId = ChatConversationModel.buildChatId(
      myUid,
      ownerId,
    );

    final fire = FirebaseFirestore.instance;

    final messageText =
        "📩 $myName طلب حجز للعقار: $propertyTitle";

    /// 💬 message
    final message = ChatMessageModel(
      id: '',
      senderId: myUid,
      text: messageText,
      createdAt: DateTime.now(),
    );

    /// 1️⃣ save message
    await fire
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toJson());

    /// 2️⃣ IMPORTANT: update conversation doc (عشان يظهر في ConversationsView)
    await fire.collection('chats').doc(chatId).set({
      "participantIds": [myUid, ownerId],

      "participantNames": {
        myUid: myName,
      },

      "participantImages": {},

      "lastMessage": messageText,
      "lastMessageAt": FieldValue.serverTimestamp(),
      "lastSenderId": myUid,
    }, SetOptions(merge: true));
  }



  Stream<int> getUnreadCount({
    required String chatId,
    required String myUid,
  }) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) {
      return snap.docs
          .where((d) => d['senderId'] != myUid)
          .length;
    });
  }


}