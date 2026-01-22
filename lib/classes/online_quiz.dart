import '../classes/question_class.dart';

class OnlineQuiz {
  final List<dynamic> quizQuestions;
  int questionIndex = 0;
  int myScore = 0;
  int opponentScore = 0;

  OnlineQuiz({
    required List<Question> signToTextQuestions,
    required List<Map<String, dynamic>> matchQuestions,
    this.questionIndex = 0, // Allow initializing from DB
  }) : quizQuestions = [...signToTextQuestions, ...matchQuestions] {
    quizQuestions.shuffle();
  }

  dynamic get currentQuestion => quizQuestions[questionIndex];

  // Scoring Logic
  void adjustScore(bool isCorrect, bool isFirst) {
    if (isCorrect && isFirst) {
      myScore += 10; // First one right gets points
    } else if (!isCorrect) {
      myScore -= 5;  // Lose points for wrong answer
    }
  }

  // Check if someone else already got it
  bool canAnswer(String? questionAnsweredByUid) {
    return questionAnsweredByUid == null || questionAnsweredByUid.isEmpty;
  }

  bool get isMatch => currentQuestion is Map;

}