class ReadingTutorial {
  final int levelNum;
  final int readingTutorial;
  final String tutorialText;
  final String tutorialImage;
  final String? webviewFile;

  ReadingTutorial({
    required this.levelNum,
    required this.readingTutorial,
    required this.tutorialText,
    required this.tutorialImage,
    required this.webviewFile,
  });

  factory ReadingTutorial.fromMap(Map<String, dynamic> map) {
    return ReadingTutorial(
      levelNum: map['levelNum'],
      readingTutorial: map['readingTutorial'],
      tutorialText: map['tutorialText'],
      tutorialImage: map['tutorialImage'],
      webviewFile: map['webview_file '],
    );
  }
}
