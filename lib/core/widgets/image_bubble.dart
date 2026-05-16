import 'package:flutter/material.dart';

class ImageBubble extends StatelessWidget {
  final String url;
  final bool isMine;

  const ImageBubble({
    super.key,
    required this.url,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
      isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}