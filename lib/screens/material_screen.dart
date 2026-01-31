import 'package:flutter/material.dart';
import 'package:sign_language_app/screens/reading_tutorial_screen.dart';

import '../classes/reading_tutorial_class.dart';
import '../classes/user_class.dart';
import '../services/general_service.dart';
import '../services/user_service.dart';

class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key, required this.readingTutorials, required this.levelDesc, required this.username});

  final List<ReadingTutorial> readingTutorials;
  final String levelDesc;
  final String username;

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  final UserService userService = UserService();
  final GeneralService generalService = GeneralService();
  UserClass? user;

  List<int> completedLessons = [];

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

  String _formatText(String tutorialText) {
    // Dart.dev. (2026). RegExp class - dart:core library - Dart API. [online]
    // Available at: https://api.dart.dev/dart-core/RegExp-class.html
    // [Accessed 27 Jan. 2026].
    final RegExp exp = RegExp(r'"([^"]*)"');
    final match = exp.firstMatch(tutorialText);

    if (match != null) {
      return match.group(1)!;
    }

    String text = tutorialText.split(' ').last.replaceAll('.', '');
    return text.toUpperCase();
  }

  @override
  void initState() {
    super.initState();

    _loadUserLocalStorage().then((_) async {
      await _loadLearningDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    int tutorials = widget.readingTutorials.length;
    int completedTutorials = widget.readingTutorials.where((t) => completedLessons.contains(t.readingTutorial)).length;
    double progress = tutorials > 0 ? completedTutorials / tutorials : 0.0;

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.orange.shade500, Colors.deepOrange.shade800]),
          ),
        ),
        title: const Text(
          "Reading Tutorials",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: widget.readingTutorials.isEmpty ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                border: Border.all(width: 2.0, color: Colors.orange.shade300),
                borderRadius: BorderRadius.circular(15.0),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.levelDesc,
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
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
                          fontSize: 18.0,
                        ),
                      ),
                      Text(
                        "$completedTutorials / $tutorials ",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.orange.shade900,
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
                      color: Colors.orange.shade900,
                      minHeight: 12.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15.0),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12.0,
                  crossAxisSpacing: 12.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: widget.readingTutorials.length,
                itemBuilder: (context, index) {
                  String text = _formatText(widget.readingTutorials[index].tutorialText);
                  bool completed = completedLessons.contains(widget.readingTutorials[index].readingTutorial);

                  return InkWell(
                    onTap: () {
                      generalService.startPrompt(
                        context,
                        () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ReadingTutorialScreen(readingTutorial: widget.readingTutorials[index], username: user?.username)),
                          );
                          await _loadLearningDetails();
                        },
                        completed ? Icons.menu_book : Icons.play_circle,
                        completed ? 'Review reading tutorial?' : 'Start reading tutorial?',
                      );
                    },
                    child: Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: completed ? Colors.deepOrange.shade200 : Colors.white,
                          border: completed ? null : Border.all(width: 2.0, color: Colors.orange.shade300),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (completed) ...[
                              Icon(
                                Icons.check_circle,
                                size: 35.0,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 5.0)
                            ],
                            Center(
                              child: Text(
                                text,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: text.length <= 2 ? 30.0 : 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange.shade800,
                                ),
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