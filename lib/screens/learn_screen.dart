import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sign_language_app/screens/material_screen.dart';

import '../classes/reading_tutorial_class.dart';
import '../classes/user_class.dart';
import '../services/general_service.dart';
import '../services/user_service.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key, required this.changeIndex});

  final Function(int) changeIndex;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final UserService userService = UserService();
  final GeneralService generalService = GeneralService();

  UserClass? user;
  List<Map<String, dynamic>> levels = [];
  int completedLevels = 0;
  List<int> completedLessons = [];
  List<ReadingTutorial> readingTutorials = [];

  // Function to load username from local storage, when already logged in.
  Future<void> _loadUserLocalStorage() async {
    user = await userService.loadUserLocalStorage();

    if (user != null) {
      setState(() {});
    }
  }

  Future<void> _loadLearningDetails() async {
    completedLevels = await userService.loadCompletedLevels(username: user?.username);
    completedLessons = await userService.loadCompletedLessons(username: user?.username);
    setState(() {});
  }

  Future<void> _loadReadingTutorials() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('readingTutorials').get();
    if (!snapshot.exists || snapshot.value == null) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    setState(() {
      readingTutorials = data.values
          .map((value) => ReadingTutorial.fromMap(Map<String, dynamic>.from(value as Map)))
          .toList();

      readingTutorials.sort((a, b) => a.readingTutorial.compareTo(b.readingTutorial));
    });
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

  @override
  void initState() {
    super.initState();
    _loadUserLocalStorage().then((_) async {
      await _loadLevels();
      await _loadLearningDetails();
      await _loadReadingTutorials();
      await generalService.loginPrompt(user, context, widget.changeIndex, false);
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

                  final List<ReadingTutorial> levelReadingTutorials = readingTutorials.where((t) => t.levelNum == level).toList();
                  int tutorials = levelReadingTutorials.length;
                  int completedTutorials = levelReadingTutorials.where((t) => completedLessons.contains(t.readingTutorial)).length;
                  double progress = tutorials > 0 ? completedTutorials / tutorials : 0.0;

                  return InkWell(
                    onTap: (level > completedLevels + 1) ? null : () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MaterialScreen(levelDesc: levelDesc, readingTutorials: levelReadingTutorials, username: user?.username ?? '')),
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
                            Row(
                              children: [
                                Icon(
                                  (level > completedLevels + 1) ? Icons.lock : ((level <= completedLevels) ? Icons.check_circle : Icons.play_circle),
                                  size: 60.0,
                                  color: (level > completedLevels + 1) ? Colors.grey : ((level <= completedLevels) ? Colors.green : Colors.deepOrange),
                                ),
                                const SizedBox(width: 10.0),
                                Text(
                                  levels[index]['name'] ?? '',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 27.0,
                                    fontWeight: FontWeight.bold,
                                    color: (level > completedLevels + 1) ? Colors.grey : ((level <= completedLevels) ? Colors.green : Colors.deepOrange),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            if (level <= completedLevels + 1) ...[
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: (level <= completedLevels) ? Colors.orange.shade100 : Colors.white,
                                  border: Border.all(width: 2.0, color: Colors.orange.shade300),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          " Level Progress",
                                          style: TextStyle(
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        Text(
                                          "$completedTutorials / $tutorials ",
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: (level > completedLevels) ? Colors.deepOrange : Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8.0),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12.0),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: Colors.orange.shade100,
                                        color: (level > completedLevels) ? Colors.deepOrange : Colors.green,
                                        minHeight: 12.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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