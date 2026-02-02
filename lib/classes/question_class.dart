enum QuestionType {
  text,
  multipleChoice,
  match,
  multipleChoiceWordsToSign,
  multipleChoiceSignToWords,
}

class Question {
  final int questionNum;
  final int? levelNum;
  final QuestionType questionType;
  final String question;
  final String answer;
  final String questionContent;

  Question({
    required this.questionNum,
    required this.levelNum,
    required this.questionType,
    required this.question,
    required this.answer,
    required this.questionContent,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      questionNum: map['questionNum'],
      levelNum: map['levelNum'],
      questionType: QuestionType.values.firstWhere(
            (e) => e.name == map['type'],
      ),
      question: map['question'],
      questionContent: map['questionContent'],
      answer: map['answer'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionNum': questionNum,
      'levelNum': levelNum,
      'type': questionType.name,
      'question': question,
      'questionContent': questionContent,
      'answer': answer,
    };
  }

}
