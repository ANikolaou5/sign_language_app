import 'package:flutter/material.dart';

class NavigationButtons extends StatelessWidget {
  const NavigationButtons({super.key, required this.answerIndex, required this.isCorrectAnswer, this.check, required this.correctAnswer, required this.questionPoints, required this.next,});

  final int? answerIndex;
  final bool isCorrectAnswer;
  final bool? check;
  final String correctAnswer;
  final int questionPoints;
  final VoidCallback next;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 2.0, color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (answerIndex != null && check!) ...[
            Icon(
              isCorrectAnswer ? Icons.check_circle : Icons.cancel,
              color: isCorrectAnswer ? Colors.green : Colors.red.shade400,
              size: 35,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrectAnswer ? "Correct answer!" : "Incorrect answer!",
                  style: TextStyle(
                    color: isCorrectAnswer ? Colors.green : Colors.red.shade400,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isCorrectAnswer && questionPoints > 0) ...[
                  Text(
                    "You earned $questionPoints points.",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else if (correctAnswer.isNotEmpty) ...[
                  Text(
                    "Correct answer:\n$correctAnswer",
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]
              ],
            ),
          ] else ...[
            Text(
              "Press 'Next' to continue...",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(width: 10.0),
          ElevatedButton(
            onPressed: next,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
            ),
            child: Text(
              'Next',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
