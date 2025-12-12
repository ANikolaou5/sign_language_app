import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/material_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key, required this.changeIndex});

  final Function(int) changeIndex;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String? username;
  Map<String, dynamic> lessons = {};

  // Function to load username from local storage, when already logged in.
  Future<void> _loadUserLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
    });
  }

  Future<void> _loadLessons() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('lessons').get();

    lessons = (snapshot.value as Map<dynamic, dynamic>)
        .map((key, value) => MapEntry(key.toString(), value));

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _loadUserLocalStorage().then((_) {
      _loadLessons().then((_) {
        setState(() {});
      });

      if (username == '') {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
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
            );
          },
        );
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
                children: lessons.entries.map((levels) {
                  Map<String, dynamic> level = (levels.value as Map<dynamic, dynamic>)
                      .map((key, value) => MapEntry(key.toString(), value));

                  List<Map<String, dynamic>> lessonsList = level.entries
                      .where((e) => e.key.startsWith('lesson'))
                      .map((e) => (e.value as Map<dynamic, dynamic>)
                      .map((key, value) => MapEntry(key.toString(), value)))
                      .toList();

                  lessonsList.sort((a, b) => (a['lessonNum'] as int).compareTo(b['lessonNum'] as int));

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
                            "Level ${level['levelNum']}",
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
                          children: lessonsList.map((lesson) {
                            int lessonNum = lesson['lessonNum'] ?? 0;
                            return Center(
                              child: Container(
                                  padding: const EdgeInsets.all(3.0),
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 2.0)
                                  ),
                                  alignment: Alignment.center,
                                  child: TextButton(
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Are you sure you want to start this lesson?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                  Navigator.push(context,
                                                      MaterialPageRoute(builder: (
                                                          context) => MaterialScreen(lesson: lesson)));
                                              }, child: const Text('Yes')
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              }, child: const Text('No'),
                                            ),
                                          ],
                                        );
                                      }
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Lesson",
                                          style: TextStyle(
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          "$lessonNum",
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