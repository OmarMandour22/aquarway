import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../features/chat/data/model/chat_message_model.dart';

class SentBubble extends StatefulWidget {
  final ChatMessageModel message;

  const SentBubble({super.key, required this.message});

  @override
  State<SentBubble> createState() => _SentBubbleState();
}

class _SentBubbleState extends State<SentBubble> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;

  Future<void> togglePlay() async {
    if (widget.message.audioUrl == null) return;

    if (isPlaying) {
      await _player.pause();
    } else {
      await _player.setUrl(widget.message.audioUrl!);
      await _player.play();
    }

    setState(() => isPlaying = !isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    final isAudio = widget.message.audioUrl != null;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: isAudio
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: togglePlay,
            ),
            const Text("Voice Message 🎤"),
          ],
        )
            : Text(widget.message.text),
      ),
    );
  }
}