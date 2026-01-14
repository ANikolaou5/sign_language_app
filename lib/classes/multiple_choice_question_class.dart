import 'package:sign_language_app/classes/question_class.dart';

class MultipleChoiceQuestion extends Question {
  final String questionContent;

  MultipleChoiceQuestion({
    required super.questionNum,
    required super.lessonNum,
    required super.questionType,
    required super.question,
    required super.answer,
    required this.questionContent,
  });

  factory MultipleChoiceQuestion.fromMap(Map<String, dynamic> map) {
    return MultipleChoiceQuestion(
      questionNum: map['questionNum'],
      lessonNum: map['lessonNum'],
      questionType: map['type'],
      question: map['question'],
      questionContent: map['questionContent'],
      answer: map['answer'],
    );
  }
}
