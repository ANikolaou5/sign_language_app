import '../classes/question_class.dart';

class Quiz {
  final List<dynamic> quizQuestions;
  int questionIndex = 0;

  Quiz({
    required List<Question> signToTextQuestions,
    required List<Map<String, dynamic>> matchQuestions,
  }) : quizQuestions = [...signToTextQuestions, ...matchQuestions] {
    quizQuestions.shuffle();
  }

  dynamic get question => quizQuestions[questionIndex];

  int get numOfQuestions => quizQuestions.length;
  bool get isCompleted => questionIndex >= quizQuestions.length - 1;

  void next() {
    questionIndex++;
  }

  bool get isMatch => question is Map;
}