import 'package:flutter/material.dart';
import 'package:sign_language_app/components/signToText_question_widget.dart';

import '../classes/question_class.dart';
import '../classes/quiz_class.dart';
import 'match_question_widget.dart';

class BuildQuiz extends StatelessWidget {
  const BuildQuiz({
    super.key,
    required this.quiz,
    required this.matchedImages,
    required this.matchedTexts,
    required this.answerIndex,
    required this.isCorrectAnswer,
    required this.options,
    required this.generalService,
    required this.questionPoints,
    required this.next,
    required this.onMatch,
    required this.onTap,
    required this.answerTextController,
  });

  final Quiz quiz;
  final Set<String> matchedImages;
  final Set<String> matchedTexts;
  final int? answerIndex;
  final bool isCorrectAnswer;
  final List<String> options;
  final dynamic generalService;
  final int questionPoints;
  final VoidCallback next;
  final Function(String, String) onMatch;
  final Function(int) onTap;
  final TextEditingController answerTextController;

  @override
  Widget build(BuildContext context) {
    final currentQuestion = quiz.question;
    return quiz.isMatch ? MatchQuestion(
      question: currentQuestion as Map<String, dynamic>,
      matchedImages: matchedImages,
      matchedTexts: matchedTexts,
      answerIndex: answerIndex,
      isCorrectAnswer: isCorrectAnswer,
      generalService: generalService,
      questionPoints: questionPoints,
      next: next,
      onMatch: onMatch,
    )
    : SignToTextQuestion(
      question: currentQuestion as Question,
      options: options,
      answerIndex: answerIndex,
      isCorrectAnswer: isCorrectAnswer,
      questionPoints: questionPoints,
      next: next,
      onTap: onTap,
      answerTextController: answerTextController,
    );
  }
}
