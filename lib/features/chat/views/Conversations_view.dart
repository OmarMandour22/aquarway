import 'package:aquarway/core/utils/app_colors.dart';
import 'package:aquarway/features/auth/data/model/user_model.dart';
import 'package:aquarway/features/chat/data/model/chat_conversation_model.dart';
import 'package:aquarway/features/chat/data/repo/chat_repo.dart';
import 'package:aquarway/features/chat/views/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConversationsView extends StatelessWidget {
  final UserModel myUser;

  const ConversationsView({
    super.key,
    required this.myUser,
  });

  @override
  Widget build(BuildContext context) {
    final repo = ChatRepo();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F4),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          'المحادثات',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),

      body: StreamBuilder<List<ChatConversationModel>>(
        stream: repo.getConversations(myUser.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.grenblak,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد محادثات بعد',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final conversations = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: conversations.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              indent: 80,
              endIndent: 16,
              color: Color(0xFFEEEEEE),
            ),

            itemBuilder: (context, i) {
              final conv = conversations[i];

              final otherId = conv.participantIds.firstWhere(
                    (id) => id != myUser.id,
                orElse: () => '',
              );

              final cachedName = conv.participantNames[otherId];
              final cachedImage = conv.participantImages[otherId];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherId)
                    .get(),
                builder: (context, userSnap) {
                  String name = cachedName ?? 'مستخدم';
                  String image = cachedImage ?? '';

                  if (userSnap.hasData && userSnap.data!.exists) {
                    final data =
                    userSnap.data!.data() as Map<String, dynamic>;

                    name = data['username'] ?? name;
                    image = data['image'] ?? image;
                  }

                  return StreamBuilder<int>(
                    stream: repo.getUnreadCount(
                      chatId: conv.id,
                      myUid: myUser.id!,
                    ),
                    builder: (context, snap) {
                      final count = snap.data ?? 0;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),

                        onTap: () async {
                          final doc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(otherId)
                              .get();

                          if (!context.mounted) return;

                          final otherUser = doc.exists
                              ? UserModel.fromJson(doc.data()!)
                              : UserModel(
                            id: otherId,
                            username: name,
                            image: image,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                myUser: myUser,
                                otherUser: otherUser,
                              ),
                            ),
                          );
                        },

                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor:
                          AppColors.grenblak.withOpacity(0.12),
                          backgroundImage:
                          image.isNotEmpty ? NetworkImage(image) : null,
                          child: image.isEmpty
                              ? Text(
                            name.isNotEmpty
                                ? name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: AppColors.grenblak,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                              : null,
                        ),

                        title: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),

                        subtitle: Text(
                          conv.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 13,
                          ),
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatDate(conv.lastMessageAt),
                              style: const TextStyle(
                                color: Color(0xFF9E9E9E),
                                fontSize: 11.5,
                              ),
                            ),

                            const SizedBox(width: 8),

                            if (count > 0)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  "$count",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);

    if (d == today) {
      return DateFormat('hh:mm a').format(dt);
    }

    if (d == today.subtract(const Duration(days: 1))) {
      return 'أمس';
    }

    return DateFormat('d/M').format(dt);
  }
}