abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatSending extends ChatState {}

class ChatSent extends ChatState {}

class ChatError extends ChatState {
  final String error;
  ChatError({required this.error});
}