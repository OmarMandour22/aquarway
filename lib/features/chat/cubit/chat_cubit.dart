import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/model/chat_conversation_model.dart';
import '../data/repo/chat_repo.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo _repo;

  ChatCubit(this._repo) : super(ChatInitial());

  static ChatCubit get(context) => BlocProvider.of(context);

  /// ================= TEXT =================
  Future<void> sendTextMessage({
    required String myUid,
    required String myName,
    required String myImage,
    required String otherUid,
    required String otherName,
    required String otherImage,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    final chatId = ChatConversationModel.buildChatId(myUid, otherUid);

    emit(ChatSending());

    try {
      await _repo.sendTextMessage(
        chatId: chatId,
        senderId: myUid,
        senderName: myName,
        senderImage: myImage,
        receiverId: otherUid,
        receiverName: otherName,
        receiverImage: otherImage,
        text: text,
      );

      emit(ChatSent());
    } catch (e) {
      emit(ChatError(error: e.toString()));
    }
  }

  /// ================= IMAGE =================
  Future<void> sendImage({
    required File file,
    required String myUid,
    required String myName,
    required String myImage,
    required String otherUid,
    required String otherName,
    required String otherImage,
  }) async {
    final chatId = ChatConversationModel.buildChatId(myUid, otherUid);

    emit(ChatSending());

    try {
      await _repo.sendImageMessage(
        chatId: chatId,
        file: file,
        senderId: myUid,
        senderName: myName,
        senderImage: myImage,
        receiverId: otherUid,
        receiverName: otherName,
        receiverImage: otherImage,
      );

      emit(ChatSent());
    } catch (e) {
      emit(ChatError(error: e.toString()));
    }
  }

  /// ================= TYPING =================
  Future<void> setTyping({
    required String myUid,
    required String otherUid,
    required bool isTyping,
  }) async {
    final chatId = ChatConversationModel.buildChatId(myUid, otherUid);

    try {
      await _repo.setTyping(
        chatId: chatId,
        userId: myUid,
        isTyping: isTyping,
      );
    } catch (_) {}
  }

  /// ================= READ =================
  Future<void> markAsRead(String chatId, String myUid) async {
    try {
      await _repo.markMessagesAsRead(chatId, myUid);
    } catch (_) {}
  }
}