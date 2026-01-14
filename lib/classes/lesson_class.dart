class Lesson {
  final int lessonNum;
  final String name;
  final int numOfQuestions;
  final int numOfReadingTutorials;
  final int numOfVideoTutorials;

  Lesson({
    required this.lessonNum,
    required this.name,
    required this.numOfQuestions,
    required this.numOfReadingTutorials,
    required this.numOfVideoTutorials,
  });

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      lessonNum: map['lessonNum'],
      name: map['name'],
      numOfQuestions: map['numOfQuestions'],
      numOfReadingTutorials: map['numOfReadingTutorials'],
      numOfVideoTutorials: map['numOfVideoTutorials'],
    );
  }
}
