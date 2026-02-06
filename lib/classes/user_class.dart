class UserClass {
  final String uid;
  final String username;
  final String? name;
  final String? surname;
  final String? email;

  final int streakNum;
  final DateTime? lastStreakDate;
  final int score;
  final int completedLevels;

  final int wins;
  final int draws;
  final int losses;

  final int dragAndDropQCount;
  final int imgToWordQCount;
  final int readTheSignQCount;
  final int signToWordsQCount;
  final int wordsToSignQCount;
  final int dragAndDropTCount;
  final int imgToWordTCount;
  final int readTheSignTCount;
  final int signToWordsTCount;
  final int wordsToSignTCount;

  final List<int> badges;
  final List<int> completedLessons;

  UserClass({
    required this.uid,
    required this.username,
    this.name,
    this.surname,
    this.email,
    required this.streakNum,
    this.lastStreakDate,
    required this.score,
    required this.completedLevels,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    required this.dragAndDropQCount,
    required this.imgToWordQCount,
    required  this.readTheSignQCount,
    required this.signToWordsQCount,
    required this.wordsToSignQCount,
    required this.dragAndDropTCount,
    required this.imgToWordTCount,
    required this.readTheSignTCount,
    required this.signToWordsTCount,
    required this.wordsToSignTCount,
    this.badges = const [],
    this.completedLessons = const [],
  });

  factory UserClass.fromFirebase(String username, Map<String, dynamic> data) {
    final learningDetails = data['learningDetails'] ?? {};
    final accountDetails = data['accountDetails'] ?? {};
    final gameStats = data['gameStats'] ?? {};
    final quizCounts = learningDetails['quizCounts'] ?? {};
    final trainCounts = learningDetails['trainCounts'] ?? {};

    List<int> dbBadges = [];
    if (learningDetails['badges'] != null) {
      dbBadges = List<int>.from(learningDetails['badges']);
    }

    List<int> dbCompletedLessons = [];
    if (learningDetails['completedLessons'] != null) {
      dbCompletedLessons = List<int>.from(learningDetails['completedLessons']);
    }

    DateTime? date;
    if (learningDetails['lastStreakDate'] != null) {
      date = DateTime.tryParse(learningDetails['lastStreakDate']);
    }

    return UserClass(
      uid: accountDetails['uid'] ?? '',
      username: accountDetails["username"],
      name: accountDetails['name'],
      surname: accountDetails['surname'],
      email: accountDetails['email'],
      streakNum: learningDetails['streakNum'] ?? 0,
      lastStreakDate: date,
      score: learningDetails['score'] ?? 0,
      completedLevels: learningDetails['completedLevels'] ?? 0,
      wins: gameStats['wins'] ?? 0,
      draws: gameStats['draws'] ?? 0,
      losses: gameStats['losses'] ?? 0,
      dragAndDropQCount: quizCounts['dragAndDropQCount'] ?? 0,
      imgToWordQCount: quizCounts['imgToWordQCount'] ?? 0,
      readTheSignQCount: quizCounts['readTheSignQCount'] ?? 0,
      signToWordsQCount: quizCounts['signToWordsQCount'] ?? 0,
      wordsToSignQCount: quizCounts['wordsToSignQCount'] ?? 0,
      dragAndDropTCount: trainCounts['dragAndDropTCount'] ?? 0,
      imgToWordTCount: trainCounts['imgToWordTCount'] ?? 0,
      readTheSignTCount: trainCounts['readTheSignTCount'] ?? 0,
      signToWordsTCount: trainCounts['signToWordsTCount'] ?? 0,
      wordsToSignTCount: trainCounts['wordsToSignTCount'] ?? 0,
      badges: dbBadges,
      completedLessons: dbCompletedLessons,
    );
  }
}