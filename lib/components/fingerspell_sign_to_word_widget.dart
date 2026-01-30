import 'package:flutter/material.dart';
import '../classes/question_class.dart';
import 'navigation_buttons_widget.dart';

class FingerspellSignToWord extends StatelessWidget {
  const FingerspellSignToWord({
    super.key,
    required this.question,
    required this.isCorrectAnswer,
    required this.check,
    required this.questionPoints,
    required this.next,
    required this.answerTextController,
  });

  final Question question;
  final bool isCorrectAnswer;
  final bool check;
  final int questionPoints;
  final VoidCallback next;
  final TextEditingController answerTextController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
            question.question,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 5.0),
        Text(
          "This question is $questionPoints points",
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 30.0),
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
          child: Column(
            children: [
              Image.asset(
                question.questionContent,
                height: 300,
                fit: BoxFit.contain,
              ),
              TextField(
                controller: answerTextController,
                enabled: !check,
                decoration: InputDecoration(
                  labelText: !check ? 'Type your answer...' : 'Answer submitted',
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
        NavigationButtons(answerIndex: check ? 1 : null, isCorrectAnswer: isCorrectAnswer, check: check, correctAnswer: question.answer, questionPoints: questionPoints, next: next,),
      ],
    );
  }
}