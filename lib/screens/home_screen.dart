import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/user_class.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.changeIndex});

  final Function(int) changeIndex;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController streakGoalTextController;
  final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
  User? user;
  List<User> users = [];

  // Function to load username from local storage, when already logged in.
  Future<void> _loadUserLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';

    if (username != '') {
      final snapshot = await usersRef.child(username).get();

      if (snapshot.exists) {
        final data =
        Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          user = User.fromFirebase(username, data);
        });
      }
    }
  }

  Future<void> _updateStreakNum() async {
    if (user == null) return;

    final userRef = usersRef.child(user!.username).child('learningDetails');
    String inputStreakGoal = streakGoalTextController.text.trim();

    await userRef.update({
      'streakNumGoal': int.tryParse(inputStreakGoal) ?? 0,
    });

    setState(() {
      user = User(
        username: user!.username,
        password: user!.password,
        name: user!.name,
        surname: user!.surname,
        email: user!.email,
        streakNum: user!.streakNum,
        streakNumGoal: int.tryParse(inputStreakGoal) ?? 0,
        score: user!.score,
        completedLessons: user!.completedLessons,
      );
    });

    Navigator.pop(context);
  }

  // Function to load the learning details of the user from the Realtime database.
  Future<void> _checkStreakGoal() async {
    if (user == null) return;

    if (user!.streakNum >= user!.streakNumGoal) {
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (context) =>
            AlertDialog(
              title: Text('Streak Goal'),
              content: TextField(
                controller: streakGoalTextController,
                autofocus: true,
                decoration: InputDecoration(
                    hintText: 'Update your streak goal..'),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await _updateStreakNum();
                  },
                  child: Text('Save'),
                )
              ],
            ),
        );
      });
    }
  }

  // Function to load all users from the Realtime database.
  Future<void> _loadUsers() async {
    final snapshot = await usersRef.get();
    if (!snapshot.exists) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    users = data.entries.map((entry) {
      return User.fromFirebase(entry.key, Map<String, dynamic>.from(entry.value as Map));
    }).toList();

    users.sort((b, a) => a.score.compareTo(b.score));
    users = users.take(3).toList();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    streakGoalTextController = TextEditingController();

    _loadUserLocalStorage().then((_) async {
      await _checkStreakGoal();
      await _loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15.0),
                Text(
                  user == null ? "Welcome!" : "Welcome, ${user!.username}",
                  style: const TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 30.0),
                Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      border: Border.all()
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _circle("Streak", user?.streakNum ?? 0),
                        _circle("Streak Goal", user?.streakNumGoal ?? 0),
                        _circle("Score", user?.score ?? 0),
                      ],
                    )
                ),
                const SizedBox(height: 30.0),
                Container(
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      border: Border.all()
                  ),
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () => widget.changeIndex(1),
                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "Continue Learning... ",
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Icon(
                            Icons.arrow_circle_right_outlined,
                            size: 30.0,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                ),
                const SizedBox(height: 30.0),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    border: Border.all(),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        "Leaderboard",
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Column(
                        children: users.map((user) {
                          return Column(
                            children: [
                              const SizedBox(height: 10.0),
                              Center(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        user.username,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        user.score.toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      )
                    ],
                  ),
                )
              ]
            ),
        ),
    );
  }
}

Widget _circle(String label, int value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.bold
        ),
      ),
      Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(width: 2.0),
        ),
        child: Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    ],
  );
}