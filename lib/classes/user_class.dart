class UserClass {
  final String uid;
  final String username;
  final String? name;
  final String? surname;
  final String? email;

  final int streakNum;
  final int streakNumGoal;
  final int score;
  final int completedLessons;

  final int wins;
  final int draws;
  final int losses;

  final List<int> badges;

  UserClass({
    required this.uid,
    required this.username,
    this.name,
    this.surname,
    this.email,
    required this.streakNum,
    required this.streakNumGoal,
    required this.score,
    required this.completedLessons,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.badges = const [],
  });

  factory UserClass.fromFirebase(String username, Map<String, dynamic> data) {
    final learningDetails = data['learningDetails'] ?? {};
    final accountDetails = data['accountDetails'] ?? {};
    final gameStats = data['gameStats'] ?? {};

    List<int> dbBadges = [];
    if (learningDetails['badges'] != null) {
      dbBadges = List<int>.from(learningDetails['badges']);
    }

    return UserClass(
      uid: accountDetails['uid'] ?? '',
      username: accountDetails["username"],
      name: accountDetails['name'],
      surname: accountDetails['surname'],
      email: accountDetails['email'],
      streakNum: learningDetails['streakNum'] ?? 0,
      streakNumGoal: learningDetails['streakNumGoal'] ?? 0,
      score: learningDetails['score'] ?? 0,
      completedLessons: learningDetails['completedLessons'] ?? 0,
      wins: gameStats['wins'] ?? 0,
      draws: gameStats['draws'] ?? 0,
      losses: gameStats['losses'] ?? 0,
      badges: dbBadges,
    );
  }
}