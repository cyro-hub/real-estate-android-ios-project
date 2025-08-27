import 'package:flutter/material.dart';

class HouseRuleItem extends StatelessWidget {
  final String label;
  const HouseRuleItem({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 253, 247, 227),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(Icons.warning, color: const Color(0xFFF38721), size: 28),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
