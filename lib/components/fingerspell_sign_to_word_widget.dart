import 'package:flutter/material.dart';
import '../classes/question_class.dart';
import 'navigation_buttons_widget.dart';

class FingerspellSignToWord extends StatelessWidget {
  const FingerspellSignToWord({
    super.key,
    required this.question,
    required this.isCorrectAnswer,
    required this.check,
    required this.darkMode,
    required this.questionPoints,
    required this.next,
    required this.answerTextController,
  });

  final Question question;
  final bool isCorrectAnswer;
  final bool check;
  final bool darkMode;
  final int questionPoints;
  final VoidCallback next;
  final TextEditingController answerTextController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 5.0),

        Text(
          question.question,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5.0),
        Text(
          "This question is worth $questionPoints points",
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 30.0),
        Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: darkMode ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [BoxShadow(
              color: Colors.orange,
              blurRadius: 2.0,
              offset: Offset(0.5, 0.5),
            )
            ],
          ),
          child: Column(
            children: [
              Image.asset(
                question.questionContent,
                height: 250,
                fit: BoxFit.contain,
              ),
              TextField(
                controller: answerTextController,
                enabled: !check,
                decoration: InputDecoration(
                  hintText: !check ? 'Type your answer...' : 'Answer submitted',
                  border: OutlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.orange.shade900,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 25.0),
        NavigationButtons(answerIndex: check ? 1 : null, isCorrectAnswer: isCorrectAnswer, check: check, darkMode: darkMode, correctAnswer: question.answer, questionPoints: questionPoints, next: next,),
      ],
    );
  }
}