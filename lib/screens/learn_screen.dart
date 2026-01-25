import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/screens/material_screen.dart';

import '../classes/lesson_class.dart';
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
  Map<int, List<Lesson>> levelLessons = {};
  Map<int, String> levelDescriptions = {};
  int completedLessons = 0;

  // Function to load username from local storage, when already logged in.
  Future<void> _loadUserLocalStorage() async {
    user = await userService.loadUserLocalStorage();

    if (user != null) {
      setState(() {});
    }
  }

  Future<void> _loadLearningDetails() async {
    completedLessons = await userService.loadCompletedLessons(username: user?.username);
    setState(() {});
  }

  Future<void> _loadLessons() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('lessons').get();
    if (!snapshot.exists) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    Map<int, List<Lesson>> levels = {};
    Map<int, String> descriptions = {};

    for (var level in data.entries) {
      final levelMap = Map<String, dynamic>.from(level.value as Map);
      final levelNum = levelMap['levelNum'] as int? ?? 0;
      descriptions[levelNum] = levelMap['levelDesc'] ?? '';

      final lessons = levelMap.entries
          .where((e) => e.key.startsWith('lesson'))
          .map((e) => Lesson.fromMap(Map<String, dynamic>.from(e.value as Map)))
          .toList();

      lessons.sort((a, b) => a.lessonNum.compareTo(b.lessonNum));

      levels[levelNum] = lessons;
    }

    setState(() {
      levelLessons = levels;
      levelDescriptions = descriptions;
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
                    "Log in for the full experience!",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10.0),
                  const Text(
                    "If you log in or register, you can earn points and badges, and appear on the leaderboard!",
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
      await _loadLessons();
      await _loadLearningDetails();
      await  _loginPrompt();
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
                children: levelLessons.entries.map((l) {
                  final level = l.key;
                  final lessons = l.value;

                  return Column(
                    children: [
                      Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange.shade400,
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Level $level",
                                style: const TextStyle(
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      Text(
                        levelDescriptions[level] ?? '',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      GridView.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12.0,
                        crossAxisSpacing: 12.0,
                        shrinkWrap: true,
                        childAspectRatio: 1.0,
                        physics: NeverScrollableScrollPhysics(),
                        children: lessons.map((lesson) {
                          return InkWell(
                            onTap: lesson.lessonNum <= completedLessons + 1 ? () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                                    child: Container(
                                      padding: const EdgeInsets.all(20.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25.0),
                                        gradient: LinearGradient(colors: [Colors.orange.shade100, Colors.white],),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            (lesson.lessonNum <= completedLessons) ? Icons.menu_book : Icons.play_circle,
                                            color: Colors.orange.shade800,
                                            size: 50,
                                          ),
                                          const SizedBox(height: 10.0),
                                          Text(
                                            (lesson.lessonNum <= completedLessons) ? 'Review lesson?' : 'Start lesson?',
                                            style: const TextStyle(
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 10.0),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                                ),
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  "No",
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.orange.shade700,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                                ),
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (
                                                          context) => MaterialScreen(lesson: lesson, username: user?.username ?? '')));
                                                  await _loadLearningDetails();
                                                },
                                                child: const Text(
                                                  "Yes",
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              );
                            }
                            : null,
                            child: Card(
                              elevation: (lesson.lessonNum > completedLessons) ? 0 : 4.0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: (lesson.lessonNum <= completedLessons) ? Colors.deepOrange.shade200 : ((lesson.lessonNum > completedLessons + 1) ? Colors.grey.shade100 : Colors.white),
                                  border: (lesson.lessonNum <= completedLessons) ? null : Border.all(width: 2.0, color: Colors.orange.shade300),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 10.0),
                                    Icon(
                                      (lesson.lessonNum > completedLessons + 1) ? Icons.lock : ((lesson.lessonNum <= completedLessons) ? Icons.check_circle : Icons.play_circle),
                                      size: 25.0,
                                      color: (lesson.lessonNum > completedLessons + 1) ? Colors.grey : Colors.black,
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      "Lesson",
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: (lesson.lessonNum > completedLessons + 1) ? Colors.grey : Colors.black,                                      ),
                                    ),
                                    Text(
                                      "${lesson.lessonNum}",
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: (lesson.lessonNum > completedLessons + 1) ? Colors.grey : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 5.0),
                    ],
                  );
                }).toList(),
              ),
            ),
        ),
    );
  }
}