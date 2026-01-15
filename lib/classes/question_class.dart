enum QuestionType {
  text,
  multipleChoice,
  match,
}

class Question {
  final int questionNum;
  final int lessonNum;
  final QuestionType questionType;
  final String question;
  final String answer;
  final String questionContent;

  Question({
    required this.questionNum,
    required this.lessonNum,
    required this.questionType,
    required this.question,
    required this.answer,
    required this.questionContent,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      questionNum: map['questionNum'],
      lessonNum: map['lessonNum'],
      questionType: QuestionType.values.firstWhere(
            (e) => e.name == map['type'],
      ),
      question: map['question'],
      questionContent: map['questionContent'],
      answer: map['answer'],
    );
  }
}
