import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool darkMode = true;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

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

    _loadTheme();
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
      body: SafeArea(
        child: levels.isEmpty ? const Center(child: CircularProgressIndicator()) : Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 10.0),

              Text(
                'Learn sign language by completing the reading tutorials below.',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
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
                      onTap: (level > completedLevels + 1) ? () {
                        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                          SnackBar(content: Text("This level is locked! Please complete the previous levels first."))
                        );
                      } : () async {
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
                            color: (level <= completedLevels) ? Colors.green : ((level > completedLevels + 1) ? Colors.grey.shade100 : (darkMode ? Colors.orange.shade300 : Colors.white)),
                            border: (level <= completedLevels) ? Border.all(width: 2, color: Colors.green.shade700) : Border.all(width: 2.0, color: Colors.orange.shade300),
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
                                    color: (level > completedLevels + 1) ? Colors.grey : ((level <= completedLevels) ? Colors.white : Colors.deepOrange),
                                  ),
                                  const SizedBox(width: 10.0),
                                  Text(
                                    levels[index]['name'] ?? '',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 27.0,
                                      fontWeight: FontWeight.bold,
                                      color: (level > completedLevels + 1) ? Colors.grey : ((level <= completedLevels) ? Colors.white : Colors.deepOrange),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              if (level <= completedLevels + 1) ...[
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          " Level Progress",
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: (level > completedLevels + 1) ? Colors.grey : ((level <= completedLevels) ? Colors.white : Colors.deepOrange),
                                          ),
                                        ),
                                        Text(
                                          "$completedTutorials / $tutorials ",
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: (level > completedLevels + 1) ? Colors.grey : ((level <= completedLevels) ? Colors.white : Colors.deepOrange),
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
                                        color: (level > completedLevels + 1) ? Colors.grey : ((level <= completedLevels) ? Colors.white : Colors.deepOrange),
                                        minHeight: 12.0,
                                      ),
                                    ),
                                  ],
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
      ),
    );
  }
}