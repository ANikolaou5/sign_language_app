import 'package:flutter/material.dart';
import '../classes/question_class.dart';
import '../classes/reading_tutorial_class.dart';
import 'mcq_widget.dart';
import 'navigation_buttons_widget.dart';

class BuildTutorial extends StatelessWidget {
  const BuildTutorial({
    super.key,
    required this.tutorial,
    required this.readingTutorial,
    required this.multipleChoiceQuestion,
    required this.tutorialIndex,
    required this.possibleAnswers,
    required this.answerIndex,
    required this.isCorrectAnswer,
    required this.check,
    required this.questionPoints,
    required this.onTap,
    required this.next,
  });

  final bool tutorial;
  final ReadingTutorial readingTutorial;
  final Question? multipleChoiceQuestion;
  final int tutorialIndex;
  final List<String> possibleAnswers;
  final int? answerIndex;
  final bool isCorrectAnswer;
  final bool check;
  final int questionPoints;
  final Function(int) onTap;
  final VoidCallback next;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5.0),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 2.0, color: Colors.orange.shade300),
            borderRadius: BorderRadius.circular(15.0),
          ),
          alignment: Alignment.center,
          child: Text(
            tutorial
              ? readingTutorial.tutorialText
              : multipleChoiceQuestion!.question,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 5.0),
        if (!tutorial) ...[
          Text(
            "This question is worth $questionPoints points",
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey.shade700,
            ),
          ),
        ],
        const SizedBox(height: 10.0),
        if(tutorial) ...[
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [BoxShadow(
                color: Colors.orange,
                blurRadius: 2.0,
                offset: Offset(0.5, 0.5),
              )
              ],
            ),
            child: Image.asset(
              readingTutorial.tutorialImage,
              height: 360,
              fit: BoxFit.contain,
            ),
          ),
        ] else ...[
          if (multipleChoiceQuestion != null) ...[
            MultipleChoiceQuestion(
              question: multipleChoiceQuestion!,
              possibleAnswers: possibleAnswers,
              answerIndex: answerIndex,
              check: check,
              onTap: onTap,
              tips: '',
            ),
          ],
        ],
        const SizedBox(height: 15.0),
        NavigationButtons(answerIndex: answerIndex, isCorrectAnswer: isCorrectAnswer, check: check, correctAnswer: '', questionPoints: questionPoints, next: next,),
      ],
    );
  }
}