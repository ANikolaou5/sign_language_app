import 'package:flutter/material.dart';

class ProgressItem extends StatelessWidget {
  const ProgressItem({super.key, required this.text, required this.num, this.icon,});

  final String text;
  final int num;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: Colors.orange.shade900,
            size: 60.0,
          ),
          const SizedBox(height: 15.0),
        ],
        Text(
          num.toString(),
          style: const TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 3.0),
        Text(
          text,
          style: TextStyle(fontSize: 14.0,),
        ),
      ],
    );
  }
}