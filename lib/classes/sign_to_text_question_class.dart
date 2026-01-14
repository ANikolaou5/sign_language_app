import 'package:sign_language_app/classes/question_class.dart';

class SignToTextQuestion extends Question {
  final String questionContent;

  SignToTextQuestion({
    required super.questionNum,
    required super.lessonNum,
    required super.questionType,
    required super.question,
    required super.answer,
    required this.questionContent,
  });

  factory SignToTextQuestion.fromMap(Map<String, dynamic> map) {
    return SignToTextQuestion(
      questionNum: map['questionNum'],
      lessonNum: map['lessonNum'],
      questionType: map['type'],
      question: map['question'],
      questionContent: map['questionContent'],
      answer: map['answer'],
    );
  }
}
