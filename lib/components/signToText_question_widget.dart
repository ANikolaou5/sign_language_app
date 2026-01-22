import 'package:flutter/material.dart';
import '../classes/question_class.dart';
import 'navigation_buttons_widget.dart';

class SignToTextQuestion extends StatelessWidget {
  const SignToTextQuestion({
    super.key,
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.isCorrectAnswer,
    required this.next,
    required this.onTap,
  });

  final Question question;
  final List<String> options;
  final int? answerIndex;
  final bool isCorrectAnswer;
  final VoidCallback next;
  final Function(int) onTap;

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
            question.question,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
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
          child: Image.asset(
            question.questionContent,
            height: 300,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 25.0),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: 2.0,
          children: List.generate(options.length, (index) {
            final selected = answerIndex == index;

            return InkWell(
              onTap: answerIndex != null ? null : () => onTap(index),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: answerIndex == null ? 1.0 : (selected ? 1.0 : 0.6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: (answerIndex != null && options[index] == question.answer)
                        ? Colors.green.shade100
                        : (selected ? Colors.red.shade100 : Colors.white),
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                      color: (answerIndex != null && options[index] == question.answer)
                          ? Colors.green.shade700
                          : (selected ? Colors.red.shade700 : Colors.orange
                          .shade200),
                      width: selected ? 3.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        options[index],
                        style: const TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (answerIndex != null &&
                          options[index] == question.answer) ...[
                        const SizedBox(width: 10.0),
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 25,
                        ),
                      ] else
                        if (selected) ...[
                          const SizedBox(width: 10.0),
                          Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 25,
                          ),
                        ]
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 25.0),
        NavigationButtons(answerIndex: answerIndex, isCorrectAnswer: isCorrectAnswer, next: next,),
      ],
    );
  }
}