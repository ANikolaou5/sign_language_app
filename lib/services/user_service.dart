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

    return UserClass(
      uid: prefs.getString('uid') ?? '',
      username: username,
      name: prefs.getString('name'),
      surname: prefs.getString('surname'),
      email: prefs.getString('email'),
      streakNum: prefs.getInt('streakNum') ?? 0,
      streakNumGoal: prefs.getInt('streakNumGoal') ?? 0,
      score: prefs.getInt('score') ?? 0,
      completedLessons: prefs.getInt('completedLessons') ?? 0,
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
    await prefs.setInt('completedLessons', user.completedLessons);
  }

  // Function to load all users from the Realtime database.
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

  Future<int> loadCompletedLessons({String? username}) async {
    if (username != null && username.isNotEmpty) {
      final DatabaseReference userRef = usersRef.child(username);
      final DataSnapshot snapshot = await userRef.get();
      int dbCompletedLessons = snapshot.child('learningDetails/completedLessons').value as int;

      return dbCompletedLessons;
    } else {
      final prefs = await SharedPreferences.getInstance();
      final completedLessons = prefs.getInt('guestCompletedLessons') ?? 0;
      return completedLessons;
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