class ReadingTutorial {
  final int lessonNum;
  final int readingTutorial;
  final String tutorialText;
  final String tutorialImage;

  ReadingTutorial({
    required this.lessonNum,
    required this.readingTutorial,
    required this.tutorialText,
    required this.tutorialImage,
  });

  factory ReadingTutorial.fromMap(Map<String, dynamic> map) {
    return ReadingTutorial(
      lessonNum: map['lessonNum'],
      readingTutorial: map['readingTutorial'],
      tutorialText: map['tutorialText'],
      tutorialImage: map['tutorialImage'],
    );
  }
}
