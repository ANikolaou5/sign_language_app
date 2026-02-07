import 'package:flutter/material.dart';

import '../classes/question_class.dart';
import 'navigation_buttons_widget.dart';

class ReadTheSignQuestion extends StatelessWidget {
  const ReadTheSignQuestion({super.key, required this.question, required this.possibleAnswers, required this.pointsMCQ, required this.answerIndex, required this.isCorrectAnswer, required this.check, required this.darkMode, required this.next, required this.onTap,});

  final Question question;
  final List<String> possibleAnswers;
  final int pointsMCQ;
  final int? answerIndex;
  final bool isCorrectAnswer;
  final bool check;
  final bool darkMode;
  final VoidCallback next;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final String correctAnswer = question.answer;

    return Column(
      children: [
        const SizedBox(height: 5.0),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: darkMode ? Colors.black : Colors.orange.shade100,
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
          "This question is worth $pointsMCQ points",
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 10.0),
        Container(
          padding: const EdgeInsets.all(12.0),
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
          child: Image.asset(
            question.questionContent,
            height: 120,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 10.0),
        Column(
          children: List.generate(possibleAnswers.length, (index) {
            final selected = answerIndex == index;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: check ? null : () => onTap(index),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: (answerIndex == null) ? 1.0 : (selected ? 1.0 : 0.6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: !check
                        ? (selected ? Colors.orange.shade100 : (darkMode ? Colors.black : Colors.white))
                        : (possibleAnswers[index] == correctAnswer
                          ? Colors.green.shade100
                          : (selected ? Colors.red.shade100 : (darkMode ? Colors.black : Colors.white))),
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                        color: !check
                          ? (selected ? Colors.orange.shade700 : Colors.orange.shade200)
                          : (possibleAnswers[index] == correctAnswer
                            ? Colors.green.shade700
                            : (selected ? Colors.red.shade700 : Colors.orange.shade200)),
                        width: selected ? 3.0 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: selected ? Colors.orange.shade700 : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 30.0),
                        Text(
                          possibleAnswers[index],
                          style: TextStyle(
                            fontSize: 20.0,
                            color: !check
                              ? (selected ? Colors.orange.shade700 : Colors.orange)
                              : (possibleAnswers[index] == correctAnswer
                              ? Colors.green.shade700
                                : (selected ? Colors.red.shade700 : Colors.orange)),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (check) ...[
                          const SizedBox(width: 30.0),
                          if (possibleAnswers[index] == correctAnswer) ...[
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 35,
                            ),
                          ]
                          else if (selected) ...[
                            const SizedBox(width: 30.0),
                            Icon(
                              Icons.cancel,
                              color: Colors.red,
                              size: 35,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 25.0),
        NavigationButtons(answerIndex: check ? 1 : null, isCorrectAnswer: isCorrectAnswer, check: check, darkMode: darkMode, correctAnswer: question.answer, questionPoints: pointsMCQ, next: next,),
      ],
    );
  }
}