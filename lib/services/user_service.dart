import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/user_class.dart';

class UserService {
  final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');

  // Function to load username from local storage, when already logged in.
  Future<UserClass?> loadUserLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username == null) return null;

    final List<String> badgesList = prefs.getStringList('badges') ?? [];
    List<int> badges = badgesList.map((n) => int.parse(n)).toList();

    final List<String> completedLessonsList = prefs.getStringList('completedLessons') ?? [];
    List<int> completedLessons = completedLessonsList.map((n) => int.parse(n)).toList();

    String? date = prefs.getString('lastStreakDate');
    DateTime? lastStreakDate = date != null ? DateTime.tryParse(date) : null;

    return UserClass(
      uid: prefs.getString('uid') ?? '',
      username: username,
      name: prefs.getString('name'),
      surname: prefs.getString('surname'),
      email: prefs.getString('email'),
      streakNum: prefs.getInt('streakNum') ?? 0,
      streakNumGoal: prefs.getInt('streakNumGoal') ?? 0,
      lastStreakDate: lastStreakDate,
      score: prefs.getInt('score') ?? 0,
      completedLevels: prefs.getInt('completedLevels') ?? 0,
      draws: prefs.getInt('draws') ?? 0,
      losses: prefs.getInt('losses') ?? 0,
      wins: prefs.getInt('wins') ?? 0,
      badges: badges,
      completedLessons: completedLessons,
    );
  }

  // Function to save user info to local storage.
  Future<void> saveUserLocalStorage(UserClass user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('username', user.username);
    await prefs.setString('uid', user.uid);
    if (user.name != null) await prefs.setString('name', user.name!);
    if (user.surname != null) await prefs.setString('surname', user.surname!);
    if (user.email != null) await prefs.setString('email', user.email!);
    await prefs.setInt('streakNum', user.streakNum);
    await prefs.setInt('streakNumGoal', user.streakNumGoal);
    await prefs.setInt('score', user.score);
    await prefs.setInt('completedLevels', user.completedLevels);
    await prefs.setInt('draws', user.draws);
    await prefs.setInt('losses', user.losses);
    await prefs.setInt('wins', user.wins);

    if (user.lastStreakDate != null) {
      await prefs.setString('lastStreakDate', user.lastStreakDate!.toIso8601String());
    }

    List<String> badges = user.badges
        .map((badgeNum) => badgeNum.toString())
        .toList();

    List<String> completedLessons = user.completedLessons
        .map((completedLessonsNum) => completedLessonsNum.toString())
        .toList();

    await prefs.setStringList('badges', badges);
    await prefs.setStringList('completedLessons', completedLessons);
  }

  Future<UserClass?> refreshUserLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username != null) {
      final DatabaseReference userRef = usersRef.child(username);
      final DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        UserClass user = UserClass.fromFirebase(username, Map<String, dynamic>.from(snapshot.value as Map));
        await saveUserLocalStorage(user);
        return user;
      }
    }
    return null;
  }

  // Function to load all users from the Realtime database sorted based on the wins of "Play Online".
  Future<List<UserClass>> loadUsersBasedOnWins() async {
    final snapshot = await usersRef.get();
    if (!snapshot.exists) return [];

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    final users = data.entries.map((entry) {
      return UserClass.fromFirebase(entry.key, Map<String, dynamic>.from(entry.value as Map));
    }).toList();

    users.sort((b, a) => a.wins.compareTo(b.wins));
    return users;
  }

  // Function to load all users from the Realtime database sorted based on the score.
  Future<List<UserClass>> loadUsers() async {
    final snapshot = await usersRef.get();
    if (!snapshot.exists) return [];

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    final users = data.entries.map((entry) {
      return UserClass.fromFirebase(entry.key, Map<String, dynamic>.from(entry.value as Map));
    }).toList();

    users.sort((b, a) => a.score.compareTo(b.score));
    return users;
  }

  // Function to load top users from the Realtime database for the leaderboard.
  Future<List<UserClass>> loadTopUsers(int num) async {
    List<UserClass> users = await loadUsers();
    users = users.take(num).toList();
    return users;
  }

  // Function to load top users from the Realtime database for the leaderboard of "Play Online".
  Future<List<UserClass>> loadTopUsersBasedOnWins(int num) async {
    List<UserClass> users = await loadUsersBasedOnWins();
    users = users.take(num).toList();
    return users;
  }

  Future<List<int>> loadCompletedLessons({String? username}) async {
    if (username != null && username.isNotEmpty) {
      final snapshot = await usersRef.child(username).child('learningDetails/completedLessons').get();

      if (snapshot.exists && snapshot.value is List) {
        return List<int>.from(snapshot.value as List);
      }
      return [];
    } else {
      final prefs = await SharedPreferences.getInstance();
      final completedLessons = prefs.getStringList('guestCompletedLessons') ?? [];
      return completedLessons.map((e) => int.parse(e)).toList();
    }
  }

  Future<int> loadCompletedLevels({String? username}) async {
    if (username != null && username.isNotEmpty) {
      final DatabaseReference userRef = usersRef.child(username);
      final DataSnapshot snapshot = await userRef.get();
      int dbCompletedLevels = snapshot.child('learningDetails/completedLevels').value as int;

      return dbCompletedLevels;
    } else {
      final prefs = await SharedPreferences.getInstance();
      final completedLevels = prefs.getInt('guestCompletedLevels') ?? 0;
      return completedLevels;
    }
  }

  // Edit user info in the Realtime database & to local storage.
  Future<void> editProfile(UserClass user) async {
    final userRef = usersRef.child(user.username).child('accountDetails');
    await userRef.update({
      'name': user.name,
      'surname': user.surname,
    });

    await saveUserLocalStorage(user);
  }
}