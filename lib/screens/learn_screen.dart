import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/screens/material_screen.dart';

import '../classes/lesson_class.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key, required this.changeIndex});

  final Function(int) changeIndex;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String? username;
  int completedLessons = 0;
  Map<int, List<Lesson>> levelLessons = {};

  // Function to load username from local storage, when already logged in.
  Future<void> _loadUserLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
    });
  }

  Future<void> _loadLearningDetails() async {
    if (username != null && username!.isNotEmpty) {
      final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
      final DatabaseReference userRef = usersRef.child(username!);
      final DataSnapshot snapshot = await userRef.get();

      int dbCompletedLessons = snapshot.child('learningDetails/completedLessons').value as int;

      setState(() {
        completedLessons = dbCompletedLessons;
      });
      return;
    } else {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        completedLessons = prefs.getInt('guestCompletedLessons') ?? 0;
      });
    }
  }

  Future<void> _loadLessons() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('lessons').get();
    if (!snapshot.exists) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    Map<int, List<Lesson>> levels = {};

    for (var level in data.entries) {
      final levelMap = Map<String, dynamic>.from(level.value as Map);
      final levelNum = levelMap['levelNum'] as int? ?? 0;

      final lessons = levelMap.entries
          .where((e) => e.key.startsWith('lesson'))
          .map((e) => Lesson.fromMap(Map<String, dynamic>.from(e.value as Map)))
          .toList();

      lessons.sort((a, b) => a.lessonNum.compareTo(b.lessonNum));

      levels[levelNum] = lessons;
    }

    setState(() {
      levelLessons = levels;
    });
  }

  Future<void> _loginPrompt() async {
    final prefs = await SharedPreferences.getInstance();

    if (username == null || username!.isEmpty) {
      bool showPrompt = prefs.getBool('showPrompt') ?? false;

      if (!showPrompt) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) =>
              AlertDialog(
                title: const Text('Log in for the full experience!'),
                content: const Text(
                  'If you log in or register, you can earn points and appear on the leaderboard!',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await prefs.setBool('showPrompt', true);
                      Navigator.pop(context);
                      widget.changeIndex(2);
                    },
                    child: const Text(
                      'Log in / Register',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  TextButton(
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
                      const SizedBox(height: 5.0),
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
                                  return AlertDialog(
                                    title: (lesson.lessonNum <= completedLessons) ? Text('Review lesson?') : Text('Start lesson?'),
                                    actions: [
                                      TextButton(
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
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (
                                                  context) => MaterialScreen(lesson: lesson, username: username ?? '')));
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