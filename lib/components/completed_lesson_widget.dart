import 'package:flutter/material.dart';

import '../classes/badge_class.dart';

class CompletedLesson extends StatelessWidget {
  const CompletedLesson({super.key, this.readingTutorial, required this.completed, required this.badges, required this.newBadge, required this.score, required this.reviewLesson, required this.isGuest, required this.timerEnd, required this.quiz, required this.darkMode, required this.streakUpdate, required this.streak,});

  final int? readingTutorial;
  final VoidCallback completed;
  final List<BadgeClass> badges;
  final bool newBadge;
  final int score;
  final bool reviewLesson;
  final bool isGuest;
  final bool timerEnd;
  final bool quiz;
  final bool darkMode;
  final bool streakUpdate;
  final int? streak;

  @override
  Widget build(BuildContext context) {
    BadgeClass? earnedBadge = badges.isNotEmpty ? badges.first : null;
    final bool earned = earnedBadge != null;

    String streakTxt = '';

    if (streakUpdate) {
      if (streak == 5) {
        streakTxt = '2';
      } else if (streak == 10) {
        streakTxt = '3';
      } else if (streak == 15) {
        streakTxt = '4';
      }
    }

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
          timerEnd ? "Time's Up!" : (score == 0 ? "Good effort, practice makes perfect!" : "Congratulations!"),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10.0),
        Text(
          quiz
          ? (timerEnd ? "You've run out of time, but you still did great! Keep practicing to get faster!" : "You have finished this quiz")
          : readingTutorial != null
            ? (!reviewLesson ? "You have finished lesson $readingTutorial" : "You have reviewed lesson $readingTutorial")
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
                color: darkMode ? Colors.black : Colors.white,
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
                ],
              ),
            ),
            const SizedBox(height: 15.0),
          ],
          if (!isGuest) ...[
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: darkMode ? Colors.black : Colors.white,
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
                  if (streakTxt != '' && score != 0) ...[
                    const SizedBox(height: 10.0),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Text(
                        "x$streakTxt Streak Bonus",
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  if (newBadge && score != 0) ...[
                    const SizedBox(height: 10.0),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Text(
                        "x2 Badge Bonus",
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
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
            'Done',
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
