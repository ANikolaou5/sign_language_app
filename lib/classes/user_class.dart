class User {
  final String username;
  final String? password;
  final String? name;
  final String? surname;
  final String? email;

  final int streakNum;
  final int streakNumGoal;
  final int score;
  final int completedLessons;

  User({
    required this.username,
    required this.password,
    this.name,
    this.surname,
    this.email,
    required this.streakNum,
    required this.streakNumGoal,
    required this.score,
    required this.completedLessons,
  });

  factory User.fromFirebase(String username, Map<String, dynamic> data) {
    final learningDetails = data['learningDetails'] ?? {};
    final accountDetails = data['accountDetails'] ?? {};

    return User(
      username: username,
      password: accountDetails['password'],
      name: accountDetails['name'],
      surname: accountDetails['surname'],
      email: accountDetails['email'],
      streakNum: learningDetails['streakNum'] ?? 0,
      streakNumGoal: learningDetails['streakNumGoal'] ?? 0,
      score: learningDetails['score'] ?? 0,
      completedLessons: learningDetails['completedLessons'] ?? 0,
    );
  }
}
