import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sign_language_app/screens/achievements_screen.dart';

import '../classes/user_class.dart';
import '../components/progress_item_widget.dart';
import '../services/user_service.dart';
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
  final UserService userService = UserService();

  UserClass? user;
  List<UserClass> users = [];
  String? errorMessage;

  // Function to load username from local storage, when already logged in.
  Future<void> _loadUserLocalStorage() async {
    user = await userService.loadUserLocalStorage();

    if (user != null) {
      setState(() {});
    }
  }

  Future<void> _resetStreakNum() async {
    if (user == null || user!.lastStreakDate == null) return;

    if (user!.streakNum != 0) {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime lastStreakDate = user!.lastStreakDate!;
      DateTime lastDate = DateTime(
          lastStreakDate.year, lastStreakDate.month, lastStreakDate.day);
      int difference = today
          .difference(lastDate)
          .inDays;

      if (difference > 1) {
        final userRef = usersRef.child(user!.username).child('learningDetails');

        await userRef.update({
          'streakNum': 0,
        });

        await userService.refreshUserLocalStorage();
        user = await userService.loadUserLocalStorage();
        setState(() {});

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0)),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  gradient: LinearGradient(colors: [
                    Colors.orange.shade100,
                    Colors.white
                  ],),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.deepOrange,
                      size: 80.0,
                    ),
                    Text(
                      "Your streak was broken!",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    const Text(
                      "It's been a while since your last lesson. Your streak has reset to 0, but don't give up!",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 18.0),
                    ),
                    const SizedBox(height: 25.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Start a new streak",
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    }
  }

  Future<void> _updateStreakNumGoal(StateSetter setDialogState) async {
    if (user == null) return;

    String inputStreakGoal = streakGoalTextController.text.trim();

    setDialogState(() {
      if (int.tryParse(inputStreakGoal) == null ||
          int.tryParse(inputStreakGoal)! <= 0) {
        errorMessage = "Please enter a number greater than 0.";
      } else if (int.tryParse(inputStreakGoal)! <= user!.streakNumGoal) {
        errorMessage =
        "Your new goal must be higher than your current goal (${user!
            .streakNumGoal}).";
      } else {
        errorMessage = null;
      }
    });

    if (errorMessage == null) {
      final userRef = usersRef.child(user!.username).child('learningDetails');

      await userRef.update({
        'streakNumGoal': int.tryParse(inputStreakGoal) ?? 0,
      });

      setState(() {
        userService.refreshUserLocalStorage();

        user = UserClass(
          uid: user!.uid,
          username: user!.username,
          name: user!.name,
          surname: user!.surname,
          email: user!.email,
          streakNum: user!.streakNum,
          streakNumGoal: int.tryParse(inputStreakGoal) ?? 0,
          score: user!.score,
          completedLessons: user!.completedLessons,
          completedLevels: user!.completedLevels,
          draws: user!.draws,
          losses: user!.losses,
          wins: user!.wins,
          badges: user!.badges,
        );
      });

      Navigator.pop(context);
    }
  }

  // Function to load the learning details of the user from the Realtime database.
  Future<void> _checkStreakGoal() async {
    if (user == null) return;

    if (user!.streakNum >= user!.streakNumGoal) {
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    gradient: LinearGradient(colors: [
                      Colors.orange.shade100,
                      Colors.white
                    ],),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.deepOrange,
                        size: 80.0,
                      ),
                      Text(
                        "Update your streak goal!",
                        style: const TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      TextField(
                        controller: streakGoalTextController,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: 'Streak number',
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.deepOrange,
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.deepOrange,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                      if (errorMessage != null) Text(errorMessage!, style: const TextStyle(color: Colors.red,)),
                      const SizedBox(height: 10.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                        ),
                        onPressed: () async {
                          await _updateStreakNumGoal(setDialogState);
                        },
                        child: const Text(
                          "Save",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
        );
      });
    }
  }

  // Function to load top users from the Realtime database for the leaderboard.
  Future<void> _loadTopUsers() async {
    users = await userService.loadTopUsers(3);

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    streakGoalTextController = TextEditingController();

    _loadUserLocalStorage().then((_) async {
      await _resetStreakNum();
      await _checkStreakGoal();
      await _loadTopUsers();
    });
  }

  @override
  void dispose() {
    streakGoalTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                        ProgressItem(text: "Streak", num: user?.streakNum ?? 0, icon: Icons.local_fire_department),
                        ProgressItem(text: "Streak Goal", num: user?.streakNumGoal ?? 0, icon: Icons.tour),
                        ProgressItem(text: "Score", num: user?.score ?? 0, icon: Icons.emoji_events),
                      ],
                    )
                  ),
                ),
                const SizedBox(height: 10.0),
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                  child: InkWell(
                    onTap: () => widget.changeIndex(1),
                    child: Container(
                      padding: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Continue Learning... ",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 22.0,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
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
                              "Leaderboard - Top 3",
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
                                  "${user.score} pts ",
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
                            InkWell(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaderboardScreen())),
                              child: Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Colors.deepOrange.shade200,
                                ),
                                child: Text(
                                  "Full Leaderboard",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.deepOrange.shade800,
                                    fontWeight: FontWeight.bold,
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
                const SizedBox(height: 10.0),
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const AchievementsScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Achievements",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 22.0,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }
}