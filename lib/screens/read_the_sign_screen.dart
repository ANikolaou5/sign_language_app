import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../classes/badge_class.dart';
import '../classes/question_class.dart';
import '../classes/user_class.dart';
import '../components/completed_lesson_widget.dart';
import '../components/read_the_sign_widget.dart';
import '../services/general_service.dart';
import '../services/user_service.dart';

class ReadTheSignScreen extends StatefulWidget {
  const ReadTheSignScreen({super.key, required this.multipleChoiceQuestions, required this.username});

  final List<Question> multipleChoiceQuestions;
  final String username;

  @override
  State<ReadTheSignScreen> createState() => _ReadTheSignScreenState();
}

class _ReadTheSignScreenState extends State<ReadTheSignScreen> {
  final GeneralService generalService = GeneralService();
  final UserService userService = UserService();

  List<Question> finalMultipleChoiceQuestions = [];
  List<String> possibleAnswers = [];
  List<BadgeClass> badges = [];
  String? answer;

  int? answerIndex;
  int questionIndex = 0;
  int score = 0;
  final int pointsMCQ = 10;

  bool completed = false;
  bool isCorrectAnswer = false;
  bool check = false;

  void _createPossibleAnswersMCQ() {
    if (finalMultipleChoiceQuestions.isEmpty) return;

    final String correctWord = finalMultipleChoiceQuestions[questionIndex].answer;

    List<String> wrongWords = widget.multipleChoiceQuestions
        .map((q) => q.answer)
        .where((a) => a != correctWord)
        .toList()..shuffle();

    setState(() {
      possibleAnswers = [
        correctWord,
        wrongWords[0],
        wrongWords[1],
        wrongWords[4],
      ]..shuffle();

      answerIndex = null;
      check = false;
      isCorrectAnswer = false;
    });
  }

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
    // Check of multipleChoice question.
    if (answerIndex == null) {
      generalService.snackBar(context, 'You should select an answer!', Colors.grey.shade600);
      return;
    }

    if (!check) {
      final String correctAnswer = finalMultipleChoiceQuestions[questionIndex].answer;

      setState(() {
        check = true;

        if (possibleAnswers[answerIndex!] != correctAnswer) {
          isCorrectAnswer = false;
        }
        else {
          isCorrectAnswer = true;
          score += pointsMCQ;
        }
      });
      return;
    }

    if (questionIndex < finalMultipleChoiceQuestions.length - 1) {
      setState(() {
        questionIndex++;
        _createPossibleAnswersMCQ();
      });
    } else {
      await _complete();
    }
  }

  @override
  void initState() {
    super.initState();

    finalMultipleChoiceQuestions = List<Question>.from(widget.multipleChoiceQuestions)..shuffle();
    _createPossibleAnswersMCQ();
  }

  @override
  Widget build(BuildContext context) {
    double progress = (questionIndex + 1) / finalMultipleChoiceQuestions.length;

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
            "Read the Sign",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: Column(
          children: [
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
                      badges: badges,
                      score: score,
                      reviewLesson: false,
                      isGuest: false,
                    ) : ReadTheSignQuestion(
                      question: finalMultipleChoiceQuestions[questionIndex],
                      possibleAnswers: possibleAnswers,
                      pointsMCQ: pointsMCQ,
                      answerIndex: answerIndex,
                      isCorrectAnswer: isCorrectAnswer,
                      check: check,
                      onTap: (index) {
                        if (!check) {
                          setState(() {
                            answerIndex = index;
                          });
                        }
                      },
                      next: _next,
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