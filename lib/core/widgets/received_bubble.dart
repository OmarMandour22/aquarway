import 'package:flutter/material.dart';
import '../../features/chat/data/model/chat_message_model.dart';

class ReceivedBubble extends StatelessWidget {
  final ChatMessageModel message;
  final String avatarUrl;

  const ReceivedBubble({
    super.key,
    required this.message,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundImage:
            avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
          ),
          const SizedBox(width: 6),

          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.isImage)
                  Image.network(message.imageUrl!, width: 200),

                if (message.isAudio)
                  const Icon(Icons.play_circle, size: 40),

                if (message.isText)
                  Text(message.text),

                const SizedBox(height: 4),

                Text(
                  _formatTime(message.createdAt),
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour}:${dt.minute}";
  }
}