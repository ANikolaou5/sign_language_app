import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/screens/material_screen.dart';

import '../classes/user_class.dart';
import '../services/user_service.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key, required this.changeIndex});

  final Function(int) changeIndex;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final UserService userService = UserService();
  UserClass? user;
  List<Map<String, dynamic>> levels = [];
  int completedLevels = 0;

  // Function to load username from local storage, when already logged in.
  Future<void> _loadUserLocalStorage() async {
    user = await userService.loadUserLocalStorage();

    if (user != null) {
      setState(() {});
    }
  }

  Future<void> _loadLearningDetails() async {
    completedLevels = await userService.loadCompletedLevels(username: user?.username);
    setState(() {});
  }

  Future<void> _loadLevels() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('levels').get();
    if (!snapshot.exists) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    List<Map<String, dynamic>> levelsList = [];

    data.forEach((key, value) {
      final levelData = Map<String, dynamic>.from(value as Map);
      levelsList.add(levelData);
    });

    levelsList.sort((a, b) => (a['levelNum'] as int).compareTo(b['levelNum'] as int));

    setState(() {
      levels = levelsList;
    });
  }

  Future<void> _loginPrompt() async {
    final prefs = await SharedPreferences.getInstance();

    if (user == null) {
      bool showPrompt = prefs.getBool('showPrompt') ?? false;

      if (!showPrompt) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            child: Container(
              padding: const EdgeInsets.all(25.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                gradient: LinearGradient(colors: [Colors.orange.shade100, Colors.white],),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Sign in for the full experience!",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10.0),
                  const Text(
                    "If you sign in/sign up, you can earn points, appear on the leaderboard and unlock more features!",
                    style: TextStyle(fontSize: 18.0),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 10.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    onPressed: () async {
                      await prefs.setBool('showPrompt', true);
                      Navigator.pop(context);
                      widget.changeIndex(3);
                    },
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    onPressed: () async {
                      await prefs.setBool('showPrompt', true);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Continue as Guest',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserLocalStorage().then((_) async {
      await _loadLevels();
      await _loadLearningDetails();
      await  _loginPrompt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: levels.isEmpty ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(height: 10.0),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                border: Border.all(width: 2.0, color: Colors.orange.shade300),
                borderRadius: BorderRadius.circular(15.0),
              ),
              alignment: Alignment.center,
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: levels.length,
                itemBuilder: (context, index) {
                  final int level = levels[index]['levelNum'];
                  final String levelDesc = levels[index]['levelDesc'];

                  return InkWell(
                    onTap: (level > completedLevels + 1) ? null : () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MaterialScreen(level: level, levelDesc: levelDesc, username: user?.username ?? '')),
                      );
                      await _loadLearningDetails();
                    },
                    child: Card(
                      elevation: (level > completedLevels) ? 0 : 4.0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          color: (level <= completedLevels) ? Colors.deepOrange.shade200 : ((level > completedLevels + 1) ? Colors.grey.shade100 : Colors.white),
                          border: (level <= completedLevels) ? null : Border.all(width: 2.0, color: Colors.orange.shade300),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 10.0),
                            Icon(
                              (level > completedLevels + 1) ? Icons.lock : ((level <= completedLevels) ? Icons.check_circle : Icons.play_circle),
                              size: 60.0,
                              color: (level > completedLevels + 1) ? Colors.grey : ((level <= completedLevels) ? Colors.green : Colors.deepOrange.shade800),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              levels[index]['name'] ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 27.0,
                                fontWeight: FontWeight.bold,
                                color: (level > completedLevels + 1) ? Colors.grey : Colors.deepOrange.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}