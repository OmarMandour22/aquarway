import 'package:aquarway/features/auth/data/model/user_model.dart';
import 'package:aquarway/features/chat/cubit/chat_cubit.dart';
import 'package:aquarway/features/chat/data/model/chat_conversation_model.dart';
import 'package:aquarway/features/chat/data/model/chat_message_model.dart';
import 'package:aquarway/features/chat/data/repo/chat_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/input_bar.dart';
import '../../../core/widgets/received_bubble.dart';
import '../../profile/views/profile_views.dart';

class ChatScreen extends StatefulWidget {
  final UserModel myUser;
  final UserModel otherUser;

  const ChatScreen({
    super.key,
    required this.myUser,
    required this.otherUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  late final String _chatId;
  late final ChatRepo _repo;

  @override
  void initState() {
    super.initState();

    _repo = ChatRepo();

    _chatId = ChatConversationModel.buildChatId(
      widget.myUser.id!,
      widget.otherUser.id!,
    );

    _repo.markMessagesAsRead(_chatId, widget.myUser.id!);
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileView(
          uid: widget.otherUser.id!,
        ),
      ),
    );
  }

  /// ================= DATE FORMAT =================
  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);

    if (d == today) return 'اليوم';
    if (d == today.subtract(const Duration(days: 1))) return 'أمس';

    return DateFormat('d/M/yyyy').format(dt);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// ================= DATE CHIP =================
  Widget _dateChip(String text) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatCubit(_repo),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5F4),

        appBar: AppBar(
          titleSpacing: 0,
          title: Row(
            children: [
              GestureDetector(
                onTap: _openProfile,
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: widget.otherUser.image != null &&
                      widget.otherUser.image!.isNotEmpty
                      ? NetworkImage(widget.otherUser.image!)
                      : null,
                  child: widget.otherUser.image == null
                      ? const Icon(Icons.person)
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Text(widget.otherUser.username ?? 'User'),
            ],
          ),
        ),

        body: Column(
          children: [

            /// ================= MESSAGES =================
            Expanded(
              child: StreamBuilder<List<ChatMessageModel>>(
                stream: _repo.getMessages(_chatId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!;

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final msg = messages[i];
                      final isMine = msg.senderId == widget.myUser.id;

                      final showDate = i == 0 ||
                          !_isSameDay(
                              messages[i - 1].createdAt,
                              msg.createdAt);

                      return Column(
                        children: [

                          /// 📅 DATE IN MIDDLE
                          if (showDate)
                            _dateChip(_formatDate(msg.createdAt)),

                          /// 💬 MESSAGE
                          Align(
                            alignment: isMine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin:
                              const EdgeInsets.symmetric(vertical: 5),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isMine
                                    ? Colors.green
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [

                                  /// TEXT
                                  Text(
                                    msg.text,
                                    style: TextStyle(
                                      color: isMine
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  /// ⏰ TIME (UNCHANGED)
                                  Text(
                                    DateFormat('hh:mm a')
                                        .format(msg.createdAt),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isMine
                                          ? Colors.white70
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            /// ================= INPUT =================
            BlocBuilder<ChatCubit, dynamic>(
              builder: (context, state) {
                final cubit = context.read<ChatCubit>();

                return InputBar(
                  onTyping: (isTyping) {
                    cubit.setTyping(
                      myUid: widget.myUser.id!,
                      otherUid: widget.otherUser.id!,
                      isTyping: isTyping,
                    );
                  },

                  onSend: (text) {
                    if (text.trim().isEmpty) return;

                    cubit.sendTextMessage(
                      myUid: widget.myUser.id!,
                      myName: widget.myUser.username ?? '',
                      myImage: widget.myUser.image ?? '',
                      otherUid: widget.otherUser.id!,
                      otherName: widget.otherUser.username ?? '',
                      otherImage: widget.otherUser.image ?? '',
                      text: text.trim(),
                    );
                  },

                  onSendImage: (file) {
                    cubit.sendImage(
                      file: file,
                      myUid: widget.myUser.id!,
                      myName: widget.myUser.username ?? '',
                      myImage: widget.myUser.image ?? '',
                      otherUid: widget.otherUser.id!,
                      otherName: widget.otherUser.username ?? '',
                      otherImage: widget.otherUser.image ?? '',
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}