import 'package:flutter/material.dart';
import '../classes/lesson_class.dart';
import '../classes/question_class.dart';
import '../classes/reading_tutorial_class.dart';
import 'mcq_widget.dart';
import 'navigation_buttons_widget.dart';

class BuildTutorial extends StatelessWidget {
  const BuildTutorial({
    super.key,
    required this.lesson,
    required this.tutorial,
    required this.readingTutorials,
    required this.multipleChoiceQuestions,
    required this.tutorialIndex,
    required this.possibleAnswers,
    required this.answerIndex,
    required this.isCorrectAnswer,
    required this.onTap,
    required this.next,
  });

  final Lesson lesson;
  final bool tutorial;
  final List<ReadingTutorial> readingTutorials;
  final List<Question> multipleChoiceQuestions;
  final int tutorialIndex;
  final List<String> possibleAnswers;
  final int? answerIndex;
  final bool isCorrectAnswer;
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
            color: Colors.orange.shade100,
            border: Border.all(width: 2.0, color: Colors.orange.shade300),
            borderRadius: BorderRadius.circular(15.0),
          ),
          alignment: Alignment.center,
          child: Text(
            lesson.name,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 15.0),
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
                ? readingTutorials[tutorialIndex].tutorialText
                : multipleChoiceQuestions[tutorialIndex].question,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
              readingTutorials[tutorialIndex].tutorialImage,
              height: 300,
              fit: BoxFit.contain,
            ),
          ),
        ] else
          ...[
            MultipleChoiceQuestion(
              question: multipleChoiceQuestions[tutorialIndex],
              possibleAnswers: possibleAnswers,
              answerIndex: answerIndex,
              onTap: onTap
            ),
          ],
        const SizedBox(height: 15.0),
        NavigationButtons(answerIndex: answerIndex, isCorrectAnswer: isCorrectAnswer, questionPoints: 0, next: next,),
      ],
    );
  }
}