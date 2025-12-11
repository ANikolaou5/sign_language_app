import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.changeIndex});

  final Function(int) changeIndex;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController streakGoalTextController;

  String? username;
  String dbStreakNum = '0';
  String? dbStreakNumGoal = '0';
  String? dbScore = '0';
  String? dbCompletedLessons = '0';
  final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');

  // Function to load username from local storage, when already logged in.
  Future<void> _loadUserLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
    });
  }

  Future<void> _updateStreakNum() async {
    final DatabaseReference userRef = usersRef.child(username!).child('learningDetails');
    String inputStreakGoal = streakGoalTextController.text.trim();

    await userRef.update({
      'streakNumGoal': inputStreakGoal,
    });

    setState(() {
      dbStreakNumGoal = inputStreakGoal;
    });

    Navigator.pop(context);
  }

  // Function to load the learning details of the user from the Realtime database.
  Future<void> _loadLearningDetails() async {
    final DatabaseReference userRef = usersRef.child(username!);
    final DataSnapshot snapshot = await userRef.get();

    dbStreakNum = snapshot.child('learningDetails/streakNum').value.toString();
    dbStreakNumGoal = snapshot.child('learningDetails/streakNumGoal').value.toString();
    dbScore = snapshot.child('learningDetails/score').value.toString();
    dbCompletedLessons = snapshot.child('learningDetails/completedLessons').value.toString();

    if (dbStreakNum == dbStreakNumGoal) {
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

  @override
  void initState() {
    super.initState();
    streakGoalTextController = TextEditingController();

    _loadUserLocalStorage().then((_) {
      _loadLearningDetails().then((_) {
        setState(() {});
      });
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
                  (username != '') ? "Welcome, $username!" : "Welcome!",
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
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Streak",
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
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
                                  dbStreakNum,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                        ),
                        const SizedBox(height: 10.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Streak Goal",
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
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
                                dbStreakNumGoal!,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Score",
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
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
                                dbScore!,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
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
                  child: Text(
                    "Leaderboard",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ]
            ),
        ),
    );
  }
}
