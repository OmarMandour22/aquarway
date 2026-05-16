import 'package:flutter/material.dart';

class DateChip extends StatelessWidget {
  final DateTime date;

  const DateChip({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _format(date),
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  String _format(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year}";
  }
}