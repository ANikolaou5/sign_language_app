import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/user_class.dart';
import 'leaderboard_screen.dart';

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
      backgroundColor: Colors.orange.shade50,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15.0),
              Text(
                user == null ? "Welcome!" : "Welcome, ${user!.username}!",
                style: const TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15.0),
              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    gradient: LinearGradient(colors: [Colors.orange.shade100, Colors.white],),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _progressItem("Streak", user?.streakNum ?? 0, Icons.local_fire_department),
                      _progressItem("Streak Goal", user?.streakNumGoal ?? 0, Icons.tour),
                      _progressItem("Score", user?.score ?? 0, Icons.emoji_events),
                    ],
                  )
                ),
              ),
              const SizedBox(height: 15.0),
              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.shade400,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: TextButton(
                    onPressed: () => widget.changeIndex(1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Continue Learning... ",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 22.0,
                          color: Colors.black,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    gradient: LinearGradient(colors: [Colors.orange.shade100, Colors.white],),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Leaderboard",
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.workspace_premium,
                            color: Colors.orange.shade900,
                            size: 35.0,
                          ),
                        ],
                      ),
                      const Divider(height: 35.0),
                      Column(
                        children: users.map((user) {
                          return Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  "${users.indexOf(user) + 1}",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade900,
                                  )
                                ),
                              ),
                              const SizedBox(width: 15.0),
                              Expanded(
                                child: Text(
                                  user.username,
                                  style: const TextStyle(fontSize: 16.0)
                                )
                              ),
                              Text(
                                "${user.score} ",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                )
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 15.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              gradient: LinearGradient(colors: [Colors.deepOrange.shade200, Colors.deepOrange.shade400],),
                            ),
                            child: TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaderboardScreen())),
                              child: Text(
                                "Full Leaderboard",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ),
            ]
          ),
        ),
      ),
    );
  }
}

Widget _progressItem(String text, int num, IconData icon) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Icon(
        icon,
        color: Colors.orange.shade900,
        size: 60.0,
      ),
      const SizedBox(height: 15.0),
      Text(
        num.toString(),
        style: const TextStyle(
          fontSize: 25.0,
          fontWeight: FontWeight.bold
        ),
      ),
      const SizedBox(height: 3.0),
      Text(
        text,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}