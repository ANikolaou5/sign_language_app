import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sign_language_app/components/train_categories_widget.dart';
import 'package:sign_language_app/screens/matching_screen.dart';
import 'package:sign_language_app/screens/fingerspell_sign_to_word_screen.dart';

import '../classes/question_class.dart';
import '../classes/user_class.dart';
import '../services/user_service.dart';

class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key, required this.changeIndex});

  final Function(int) changeIndex;

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  final UserService userService = UserService();
  UserClass? user;

  List<Question> signToTextQuestions = [];
  List<Map<String, dynamic>> matchQuestions = [];

  Future<void> _loadQuestions() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('questions').get();
    if (!snapshot.exists || snapshot.value == null) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    List<Question> allQuestions = data.values
      .map((value) =>
      Question.fromMap(Map<String, dynamic>.from(value as Map)))
      .where((q) => q.levelNum == null)
      .toList();

    setState(() {
      signToTextQuestions = allQuestions
          .where((q) => q.questionType == QuestionType.text)
          .toList()
        ..sort((a, b) => a.questionNum.compareTo(b.questionNum));
    });

  }

  void _createMatchQuestions() {
    final List<String> wordList = ["CAT", "BOX", "ZIP", "RED", "SKY", "FUN", "LOW"];
    matchQuestions.clear();

    for (String word in wordList) {
      List<String> chars = word.toUpperCase().split('');
      final List<Map<String, String>> correctPairs = chars.map((char) {
        return {
          'image': 'assets/images/$char.png',
          'text': char,
        };
      }).toList();

      final List<Map<String, String>> shuffledPairs = List<Map<String, String>>.from(correctPairs)..shuffle();

      matchQuestions.add({
        'correctPairs': correctPairs,
        'shuffledPairs': shuffledPairs,
      });
    }
  }

  // Function to load username from local storage, when already logged in.
  Future<void> _loadUserLocalStorage() async {
    user = await userService.loadUserLocalStorage();

    if (user != null) {
      setState(() {});
    }
  }

  Future<void> _loginPrompt() async {
    if (user == null) {
      showDialog(
        context: context,
        barrierDismissible: false,
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
                  "Sign in required for using this feature!",
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
                  onPressed: () {
                    Navigator.pop(context);
                    widget.changeIndex(5);
                  },
                  child: const Text(
                    'Sign in',
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

  @override
  void initState() {
    super.initState();
    _loadUserLocalStorage().then((_) async {
      await _loginPrompt();
      await _loadQuestions();
      _createMatchQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: Padding(
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
            TrainCategories(
              name: "DRAG & DROP TO FINGERSPELL",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MatchingScreen(matchQuestions: matchQuestions, username: user!.username),
                  ),
                );
              },
            ),
            const SizedBox(height: 10.0),
            TrainCategories(
              name: "READ THE SIGN",
              onTap: () {},
            ),
            const SizedBox(height: 10.0),
            TrainCategories(
              name: "FINGERSPELL IMAGE TO WORD",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FingerspellSignToWordScreen(signToTextQuestions: signToTextQuestions, username: user!.username),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}