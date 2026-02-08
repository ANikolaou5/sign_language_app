import 'package:flutter/material.dart';

class ProgressItem extends StatelessWidget {
  const ProgressItem({super.key, required this.text, required this.num, this.icon, this.condensed = false});

  final String text;
  final int num;
  final IconData? icon;
  final bool condensed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: !condensed ? BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black.withAlpha(50), Colors.black.withAlpha(20), Colors.black.withAlpha(50)],
          begin: AlignmentGeometry.topCenter
        ),
        border: Border.all(
          color: Colors.white54
        ),
        borderRadius: BorderRadiusGeometry.circular(10),
      ) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: Colors.white,
              size: 60.0,
            ),
            const SizedBox(height: 5.0),
          ],
          Text(
            num.toString(),
            style: const TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              color: Colors.white
            ),
          ),
          const SizedBox(height: 3.0),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.0, color: Colors.white),
          ),
        ],
      ),
    );
  }
}