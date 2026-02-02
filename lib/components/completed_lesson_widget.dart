import 'package:flutter/material.dart';

import '../classes/badge_class.dart';

class CompletedLesson extends StatelessWidget {
  const CompletedLesson({super.key, this.readingTutorial, required this.completed, required this.badges, required this.score, required this.reviewLesson, required this.isGuest, required this.timerEnd, required this.quiz,});

  final int? readingTutorial;
  final VoidCallback completed;
  final List<BadgeClass> badges;
  final int score;
  final bool reviewLesson;
  final bool isGuest;
  final bool timerEnd;
  final bool quiz;

  @override
  Widget build(BuildContext context) {
    BadgeClass? earnedBadge = badges.isNotEmpty ? badges.first : null;
    final bool earned = earnedBadge != null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.stars,
          color: Colors.deepOrange,
          size: 100,
        ),
        const SizedBox(height: 20.0),
        Text(
          timerEnd ? "Time's Up!" : "Congratulations!",
          style: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10.0),
        Text(
          quiz
          ? (timerEnd ? "You've run out of time, but you still did great! Keep practicing to get faster!" : "You have finished this quiz")
          : readingTutorial != null
            ? (!reviewLesson ? "You have finished the reading tutorial $readingTutorial" : "You have reviewed the reading tutorial $readingTutorial")
            : "You have finished your training",
          style: const TextStyle(fontSize: 20.0),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 25.0),
        if (!reviewLesson && !isGuest) ...[
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
                  "$score points",
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
        ],
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            if (quiz){
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            padding: const EdgeInsets.all(15.0),
          ),
          child: const Text(
            ' Exit ',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
