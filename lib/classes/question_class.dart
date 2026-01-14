import 'package:sign_language_app/classes/sign_to_text_question_class.dart';

import 'multiple_choice_question_class.dart';

abstract class Question {
  final int questionNum;
  final int lessonNum;
  final String questionType;
  final String question;
  final String answer;

  Question({
    required this.questionNum,
    required this.lessonNum,
    required this.questionType,
    required this.question,
    required this.answer,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    switch (map['type']) {
      case 'multipleChoice':
        return MultipleChoiceQuestion.fromMap(map);
      case 'text':
        return SignToTextQuestion.fromMap(map);
      default:
        throw Exception('Unknown question type');
    }
  }
}
