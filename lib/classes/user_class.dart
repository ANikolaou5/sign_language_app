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
    this.badges = const [],
    this.completedLessons = const [],
  });

  factory UserClass.fromFirebase(String username, Map<String, dynamic> data) {
    final learningDetails = data['learningDetails'] ?? {};
    final accountDetails = data['accountDetails'] ?? {};
    final gameStats = data['gameStats'] ?? {};

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
      badges: dbBadges,
      completedLessons: dbCompletedLessons,
    );
  }
}