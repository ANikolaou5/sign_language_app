class ReadingTutorial {
  final int levelNum;
  final int readingTutorial;
  final String tutorialText;
  final String tutorialImage;

  ReadingTutorial({
    required this.levelNum,
    required this.readingTutorial,
    required this.tutorialText,
    required this.tutorialImage,
  });

  factory ReadingTutorial.fromMap(Map<String, dynamic> map) {
    return ReadingTutorial(
      levelNum: map['levelNum'],
      readingTutorial: map['readingTutorial'],
      tutorialText: map['tutorialText'],
      tutorialImage: map['tutorialImage'],
    );
  }
}
