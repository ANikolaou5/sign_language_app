import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child(
    'users',
  );
  final UserService userService = UserService();

  UserClass? user;
  List<UserClass> users = [];
  String? errorMessage;
  bool darkMode = false;

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
        lastStreakDate.year,
        lastStreakDate.month,
        lastStreakDate.day,
      );
      int difference = today.difference(lastDate).inDays;

      if (difference > 1) {
        final userRef = usersRef.child(user!.username).child('learningDetails');

        await userRef.update({'streakNum': 0});

        await userService.refreshUserLocalStorage();
        user = await userService.loadUserLocalStorage();
        setState(() {});

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  gradient: LinearGradient(
                    colors:
                        darkMode
                            ? [Colors.grey.shade900, Colors.black]
                            : [Colors.orange.shade100, Colors.white],
                  ),
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
                      "It's been a while since your last training/quiz. Your streak has reset to 0, but don't give up!",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 18.0),
                    ),
                    const SizedBox(height: 25.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Start a new streak",
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
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

  // Function to load top users from the Realtime database for the leaderboard.
  Future<void> _loadTopUsers() async {
    users = await userService.loadTopUsers(3);

    setState(() {});
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    streakGoalTextController = TextEditingController();
    _loadTheme();
    _loadUserLocalStorage().then((_) async {
      await _resetStreakNum();
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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: const AssetImage("assets/logos/logo1.png"),
                    height: 100.0,
                  ),
                ),

                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    "SiLAC",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                if (user != null) ...[
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors:
                              darkMode
                                  ? [Colors.grey.shade900, Colors.black]
                                  : [
                                    Colors.orange.shade500,
                                    Colors.deepOrange.shade800,
                                  ],
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Column(
                        children: [
                          Text(
                            user == null
                                ? "Welcome!"
                                : "Welcome, ${user!.username}!",
                            style: const TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(height: 15),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ProgressItem(
                                text: "Streak",
                                num: user?.streakNum ?? 0,
                                icon: Icons.local_fire_department,
                              ),
                              ProgressItem(
                                text: "Score",
                                num: user?.score ?? 0,
                                icon: Icons.emoji_events,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                ],

                user == null ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "SiLAc is a mobile application for learning ASL using gamified, interactive activities that help users learn sign language through various features.",
                    textAlign: TextAlign.center,
                  ),
                ) : Container(),

                // SizedBox(height: 10,),

                //Start/continue learning...
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: InkWell(
                    onTap: () => widget.changeIndex(1),
                    child: Container(
                      padding: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            user == null ? "Start learning" : "Continue Learning",
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                //View achievements
                user != null ? Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
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
                            "View achievements",
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ) : Container(),

                // Card(
                //   elevation: 4.0,
                //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                //   child: InkWell(
                //     onTap: () => ,
                //     child: Container(
                //       padding: const EdgeInsets.all(15.0),
                //       decoration: BoxDecoration(
                //         color: Colors.deepOrange,
                //         borderRadius: BorderRadius.circular(15.0),
                //       ),
                //       child:Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //
                //
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 10.0),
                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      gradient: LinearGradient(
                        colors:
                            darkMode
                                ? [Colors.grey.shade900, Colors.black]
                                : [
                                  Colors.orange.shade800,
                                  Colors.orange.shade500,
                                ],
                        begin: AlignmentGeometry.bottomCenter,
                        // end: AlignmentGeometry.bottomCenter
                      ),
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
                                color: Colors.white
                              ),
                            ),
                            Icon(
                              Icons.workspace_premium,
                              color: Colors.white,
                              size: 35.0,
                            ),
                          ],
                        ),
                        const Divider(height: 35.0),
                        Column(
                          children:
                              users.map((user) {
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
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15.0),
                                    Expanded(
                                      child: Text(
                                        user.username,
                                        style: const TextStyle(fontSize: 16.0, color: Colors.white),
                                      ),
                                    ),
                                    Text(
                                      "${user.score} pts ",
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
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
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const LeaderboardScreen(),
                                    ),
                                  ),
                              child: Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Colors.orange.shade100,
                                ),
                                child: Text(
                                  "Full Leaderboard",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
