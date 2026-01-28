import 'package:flutter/material.dart';

import '../classes/question_class.dart';

class MultipleChoiceQuestion extends StatelessWidget {
  const MultipleChoiceQuestion({super.key, required this.question, required this.possibleAnswers, required this.answerIndex, required this.check, required this.onTap,});

  final Question question;
  final List<String> possibleAnswers;
  final int? answerIndex;
  final bool check;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final String correctAnswer = question.answer;

    return Column(
      children: [
        CircleAvatar(
          radius: 32.0,
          backgroundColor: Colors.orange.shade700,
          child: Text(
            question.questionContent,
            style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 5.0),
        Column(
          children: List.generate(3, (index) {
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
                        ? (selected ? Colors.orange.shade100 : Colors.white)
                        : (possibleAnswers[index] == correctAnswer
                          ? Colors.green.shade100
                          : (selected ? Colors.red.shade100 : Colors.white)),
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
                        Image.asset(
                          possibleAnswers[index],
                          height: 110,
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
        if (check) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 2.0, color: Colors.orange.shade300),
                borderRadius: BorderRadius.circular(15.0),
              ),
              alignment: Alignment.center,
              child: Text(
                'Tips:\n',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}