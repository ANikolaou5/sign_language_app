import 'package:flutter/material.dart';

import '../classes/badge_class.dart';

class CompletedLesson extends StatelessWidget {
  const CompletedLesson({super.key, required this.lessonNum, required this.completed, required this.badges,});

  final int lessonNum;
  final VoidCallback completed;
  final List<BadgeClass> badges;

  @override
  Widget build(BuildContext context) {
    BadgeClass? earnedBadge = badges.cast<BadgeClass?>().firstWhere((b) => b?.lessonNum == lessonNum, orElse: () => null,);
    final bool earned = earnedBadge != null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 30.0),
        Icon(
          Icons.stars,
          color: Colors.orange.shade700,
          size: 100,
        ),
        const SizedBox(height: 20.0),
        const Text(
          "Congratulations!",
          style: TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 10.0),
        Text(
          "You have finished Lesson $lessonNum",
          style: const TextStyle(fontSize: 20.0),
        ),
        const SizedBox(height: 25.0),
        if (earned) ...[
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Column(
              children: [
                const Text(
                  "Badge earned",
                  style: TextStyle(fontSize: 20.0,),
                ),
                Image.asset(
                  earnedBadge.badgeImage,
                  height: 90,
                ),
                Text(
                  earnedBadge.badgeName,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  earnedBadge.badgeDesc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15.0),
        ],
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Colors.orange.shade300),
          ),
          child: Column(
            children: [
              Text(
                "Score earned",
                style: TextStyle(fontSize: 20.0,),
              ),
              Text(
                "+10 points",
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25.0),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            padding: const EdgeInsets.all(15.0),
          ),
          child: const Text(
            ' Exit ',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}