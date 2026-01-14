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
    if (username == null || username!.isEmpty) return;

    final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
    final DatabaseReference userRef = usersRef.child(username!);
    final DataSnapshot snapshot = await userRef.get();

    int dbCompletedLessons = snapshot.child('learningDetails/completedLessons').value as int;

    setState(() {
      completedLessons = dbCompletedLessons;
    });
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

  @override
  void initState() {
    super.initState();

    _loadUserLocalStorage().then((_) async {
      if (username == null || username!.isEmpty) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Login required!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.changeIndex(2);
                },
                child: const Text(
                  'Log in / Sign in',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ],
          ),
        );
      } else {
        await _loadLessons();
        await _loadLearningDetails();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        Container(
                          padding: const EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                              color: Colors.purple.shade100,
                              border: Border.all(width: 2.0)
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Level $level",
                            style: const TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15.0),
                        GridView.count(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 10.0,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: lessons.map((lesson) {
                            return Center(
                              child: InkWell(
                                onTap: lesson.lessonNum <= completedLessons + 1 ? () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: (lesson.lessonNum <= completedLessons) ? Text('Review lesson') : Text('Start lesson'),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (
                                                    context) => MaterialScreen(lesson: lesson, username: username ?? '')));
                                              await _loadLearningDetails();
                                            }, child: Row(
                                              children: [
                                                Text(
                                                  (lesson.lessonNum <= completedLessons) ? "Review " : "Start ",
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
                                        ],
                                      );
                                    }
                                  );
                                }
                                : null,
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: (lesson.lessonNum <= completedLessons) ? Colors.green.shade300 : Colors.white,
                                    border: Border.all(width: 2.0),
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      if (lesson.lessonNum > completedLessons + 1) ...[
                                        Icon(
                                          Icons.lock,
                                          size: 30.0,
                                          color: Colors.black,
                                        ),
                                      ] else if (lesson.lessonNum <= completedLessons) ...[
                                        Icon(
                                          Icons.check_circle,
                                          size: 30.0,
                                          color: Colors.black,
                                        ),
                                      ] else ...[
                                        Icon(
                                          Icons.play_circle,
                                          size: 30.0,
                                          color: Colors.black,
                                        ),
                                      ],
                                      Text(
                                        "Lesson",
                                        style: TextStyle(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        "${lesson.lessonNum}",
                                        style: TextStyle(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 15.0),
                      ],
                  );
                }).toList(),
              ),
            ),
        ),
    );
  }
}