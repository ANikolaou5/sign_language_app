import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sign_language_app/components/signToText_question_widget.dart';

import '../classes/question_class.dart';
import '../classes/user_class.dart';
import '../components/completed_lesson_widget.dart';
import '../services/general_service.dart';
import '../services/user_service.dart';

class FingerspellSignToWordScreen extends StatefulWidget {
  const FingerspellSignToWordScreen({super.key, required this.signToTextQuestions, required this.username});

  final List<Question> signToTextQuestions;
  final String username;

  @override
  State<FingerspellSignToWordScreen> createState() => _FingerspellSignToWordScreenState();
}

class _FingerspellSignToWordScreenState extends State<FingerspellSignToWordScreen> {
  final GeneralService generalService = GeneralService();
  final UserService userService = UserService();
  late TextEditingController answerTextController;
  late List<Question> finalQuestions;

  final int questionPoints = 20;
  final int questionsToDisplay = 7;
  int score = 0;
  int questionIndex = 0;
  int? answerIndex;

  bool completed = false;
  bool isCorrectAnswer = false;
  bool check = false;

  Future<void> _complete() async {
    final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
    final userRef = usersRef.child(widget.username);
    final DataSnapshot snapshot = await userRef.get();
    UserClass user = UserClass.fromFirebase(widget.username, Map<String, dynamic>.from(snapshot.value as Map));

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    int streak = user.streakNum;

    if (user.lastStreakDate != null) {
      DateTime lastStreakDate = user.lastStreakDate!;
      DateTime lastDate = DateTime(lastStreakDate.year, lastStreakDate.month, lastStreakDate.day);
      int difference = today.difference(lastDate).inDays;

      if (difference == 1) {
        streak += 1;
      } else if (difference > 1) {
        streak = 1;
      }
    } else {
      streak = 1;
    }

    await userRef.update({
      'learningDetails': {
        'streakNum': streak,
        'streakNumGoal': user.streakNumGoal,
        'lastStreakDate': today.toIso8601String(),
        'score': user.score + score,
        'completedLevels': user.completedLevels,
        'badges': user.badges,
        'completedLessons': user.completedLessons,
      }
    });

    setState(() {
      completed = true;
      isCorrectAnswer = false;
      userService.refreshUserLocalStorage();
    });
  }

  void _next() async {
    final inputAnswer = answerTextController.text.trim().toUpperCase();
    final correctAnswer = finalQuestions[questionIndex].answer.toUpperCase();

    if (inputAnswer.isEmpty) {
      generalService.snackBar(context, 'You should type an answer!', Colors.grey.shade600);
      return;
    }

    if (!check) {
      setState(() {
        check = true;
        if (inputAnswer == correctAnswer) {
          isCorrectAnswer = true;
          score += questionPoints;
        } else {
          isCorrectAnswer = false;
        }
      });
      return;
    }

    if (questionIndex < finalQuestions.length - 1) {
      setState(() {
        questionIndex++;
        check = false;
        isCorrectAnswer = false;
        answerTextController.clear();
      });
    } else {
      await _complete();
    }
  }

  @override
  void initState() {
    super.initState();

    final shuffledQuestions = List<Question>.from(widget.signToTextQuestions)..shuffle();
    finalQuestions = shuffledQuestions.take(questionsToDisplay).toList();
    answerTextController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    double progress = (questionIndex + 1) / questionsToDisplay;

    // GaneshTamang (2024). Flutter PopScope for android back button to leave app showing black screen instead of going to home screen of android. [online] GitHub.
    // Available at: https://github.com/GaneshTamang/flast_chat_firebase_example/issues/1
    // [Accessed 3 Dec. 2025].
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
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
                        'Are you sure you want to exit this training?',
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        "Your progress in this training will not be saved until you finish.",
                        style: TextStyle(fontSize: 18.0),
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade700,
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
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
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
      },
      child: Scaffold(
        backgroundColor: Colors.orange.shade50,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.orange.shade500, Colors.deepOrange.shade800]),
            ),
          ),
          title: const Text(
            "Fingerspell Image to Word",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: Column(
          children: [
            // Flutter.dev. (2024). LinearProgressIndicator class - material library - Dart API. [online]
            // Available at: https://api.flutter.dev/flutter/material/LinearProgressIndicator-class.html
            // [Accessed 16 Jan. 2026].
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.orange.shade100,
              color: Colors.orange.shade900,
              minHeight: 8.0,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Center(
                    child: completed ? CompletedLesson(
                      completed: () => Navigator.pop(context),
                      badges: [],
                      score: score,
                      reviewLesson: false,
                      isGuest: false,
                    ) : SignToTextQuestion(
                      question: finalQuestions[questionIndex],
                      check: check,
                      isCorrectAnswer: isCorrectAnswer,
                      questionPoints: questionPoints,
                      next: _next,
                      answerTextController: answerTextController,
                    )
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}