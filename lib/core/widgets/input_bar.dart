import 'dart:io';
import 'package:flutter/material.dart';

class InputBar extends StatefulWidget {
  final Function(String text) onSend;
  final Function(File file) onSendImage;
  final Function(bool isTyping) onTyping;

  const InputBar({
    super.key,
    required this.onSend,
    required this.onSendImage,
    required this.onTyping,
  });

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final TextEditingController _controller = TextEditingController();
  bool hasText = false;

  void _sendText() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSend(text);
    _controller.clear();

    setState(() {
      hasText = false;
    });

    widget.onTyping(false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [

          /// 📎 IMAGE BUTTON ONLY
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: () async {
              // TODO: image picker
              // widget.onSendImage(file);
            },
          ),

          /// ✏️ TEXT FIELD
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _controller,
                onChanged: (value) {
                  final typing = value.trim().isNotEmpty;

                  setState(() {
                    hasText = typing;
                  });

                  widget.onTyping(typing);
                },
                onSubmitted: (_) => _sendText(),
                decoration: const InputDecoration(
                  hintText: "اكتب رسالة...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          /// 📤 SEND BUTTON
          IconButton(
            icon: Icon(
              Icons.send,
              color: hasText ? Colors.green : Colors.grey,
            ),
            onPressed: hasText ? _sendText : null,
          ),
        ],
      ),
    );
  }
}