import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:sign_language_app/components/fingerspell_sign_to_word_widget.dart';

import '../classes/badge_class.dart';
import '../classes/question_class.dart';
import '../classes/user_class.dart';
import '../components/completed_lesson_widget.dart';
import '../services/general_service.dart';
import '../services/user_service.dart';

class FingerspellSignToWordScreen extends StatefulWidget {
  const FingerspellSignToWordScreen({super.key, required this.signToTextQuestions, required this.username, required this.quiz, required this.timer, this.difficulty,});

  final List<Question> signToTextQuestions;
  final String username;
  final bool quiz;
  final bool timer;
  final String? difficulty;

  @override
  State<FingerspellSignToWordScreen> createState() => _FingerspellSignToWordScreenState();
}

class _FingerspellSignToWordScreenState extends State<FingerspellSignToWordScreen> {
  final GeneralService generalService = GeneralService();
  final UserService userService = UserService();
  late TextEditingController answerTextController;
  late List<Question> finalQuestions;
  late UserClass? user;
  List<BadgeClass> badges = [];

  final int questionPoints = 20;
  final int questionsToDisplay = 7;
  int score = 0;
  int questionIndex = 0;
  int? answerIndex;
  int difference = 0;

  bool completed = false;
  bool isCorrectAnswer = false;
  bool check = false;
  bool timerEnd = false;
  late DateTime endTime;

  Future<void> _complete() async {
    List<int> dbBadges = List<int>.from(user!.badges);

    if (!timerEnd) {
      difference = await generalService.complete(widget.username, score);
      user = await userService.refreshUserLocalStorage();
    }

    final badgesSnapshot = await FirebaseDatabase.instance.ref().child('badges').get();

    if (badgesSnapshot.exists) {
      final Map<dynamic, dynamic> badgesMap = badgesSnapshot.value as Map;
      badges.clear();

      for (var entry in badgesMap.entries) {
        final data = Map<String, dynamic>.from(entry.value as Map);

        if (data['streak'] == user!.streakNum) {
          int badgeNum = data['badgeNum'] as int;

          if (!dbBadges.contains(badgeNum)) {
            dbBadges.add(badgeNum);
            badges.add(BadgeClass.fromMap(data));
          }
        }
      }
    }

    final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
    final userRef = usersRef.child(widget.username);

    await userRef.update({
      'learningDetails/badges': dbBadges,
    });

    setState(() {
      completed = true;
      isCorrectAnswer = false;
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
          score += widget.quiz ? questionPoints * 2 : questionPoints;
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

    endTime = generalService.calculateEndTime(widget.signToTextQuestions.length, widget.difficulty);
    final shuffledQuestions = List<Question>.from(widget.signToTextQuestions)..shuffle();
    finalQuestions = shuffledQuestions.take(questionsToDisplay).toList();
    answerTextController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    double progress = (questionIndex + 1) / finalQuestions.length;

    // GaneshTamang (2024). Flutter PopScope for android back button to leave app showing black screen instead of going to home screen of android. [online] GitHub.
    // Available at: https://github.com/GaneshTamang/flast_chat_firebase_example/issues/1
    // [Accessed 3 Dec. 2025].
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        if (widget.quiz) {
          generalService.exitPrompt(context, 'quiz');
        } else {
          generalService.exitPrompt(context, 'training');
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.orange.shade50,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
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
              if (widget.timer && !completed)...[
                const SizedBox(height: 10.0),
                // GeeksforGeeks (2024). Flutter Countdown Timer. [online] GeeksforGeeks.
                // Available at: https://www.geeksforgeeks.org/flutter/flutter-countdown-timer/
                // [Accessed 31 Jan. 2026].
                TimerCountdown(
                  format: CountDownTimerFormat.minutesSeconds,
                  enableDescriptions: false,
                  endTime: endTime,
                  onEnd: () {
                    setState(() {
                      timerEnd = true;
                    });
                    _complete();
                  },
                  timeTextStyle: TextStyle(
                    color: Colors.deepOrange.shade800,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                  colonsTextStyle: TextStyle(
                    color: Colors.deepOrange.shade800,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
                        quiz: widget.quiz,
                        timerEnd: timerEnd,
                        streak: user?.streakNum,
                        streakUpdate: difference == 1 ? true : false,
                      ) : FingerspellSignToWord(
                        question: finalQuestions[questionIndex],
                        check: check,
                        isCorrectAnswer: isCorrectAnswer,
                        questionPoints: widget.quiz ? questionPoints * 2 : questionPoints,
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
      ),
    );
  }
}