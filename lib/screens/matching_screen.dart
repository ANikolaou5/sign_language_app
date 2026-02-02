import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';

import '../components/completed_lesson_widget.dart';
import '../components/match_question_widget.dart';
import '../services/general_service.dart';
import '../services/user_service.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key, required this.matchQuestions, required this.username, required this.quiz, required this.timer, this.difficulty,});

  final List<Map<String, dynamic>> matchQuestions;
  final String username;
  final bool quiz;
  final bool timer;
  final String? difficulty;

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  final GeneralService generalService = GeneralService();
  final UserService userService = UserService();
  late List<Map<String, dynamic>> finalMatchQuestions;

  Set<String> matchedImages = {};
  Set<String> matchedTexts = {};

  final int questionPoints = 30;
  int score = 0;
  int questionIndex = 0;
  int? answerIndex;

  bool completed = false;
  bool isCorrectAnswer = false;
  bool check = false;
  bool timerEnd = false;

  late DateTime endTime;

  Future<void> _complete() async {
    if (!timerEnd) {
      await generalService.complete(widget.username, score);
      await userService.refreshUserLocalStorage();
    }

    setState(() {
      completed = true;
      isCorrectAnswer = false;
    });
  }

  void _next() async {
    if (answerIndex == null) {
      generalService.snackBar(context, 'You should match all images!', Colors.grey.shade600);
      return;
    }

    if (questionIndex < finalMatchQuestions.length - 1) {
      setState(() {
        questionIndex++;
        matchedImages.clear();
        matchedTexts.clear();
        answerIndex = null;
        check = false;
        isCorrectAnswer = false;
      });
    } else {
      await _complete();
    }
  }

  @override
  void initState() {
    super.initState();

    endTime = generalService.calculateEndTime(widget.matchQuestions.length, widget.difficulty);
    finalMatchQuestions = List<Map<String, dynamic>>.from(widget.matchQuestions)..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    double progress = (questionIndex + 1) / finalMatchQuestions.length;

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
              "Drag & Drop to Fingerspell",
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
                        badges: [],
                        score: score,
                        reviewLesson: false,
                        isGuest: false,
                        timerEnd: timerEnd,
                        quiz: widget.quiz,
                      ) : MatchQuestion(
                        question: finalMatchQuestions[questionIndex],
                        matchedImages: matchedImages,
                        matchedTexts: matchedTexts,
                        answerIndex: answerIndex,
                        isCorrectAnswer: isCorrectAnswer,
                        check: check,
                        questionPoints: widget.quiz ? questionPoints * 2 : questionPoints,
                        onMatch: (img, txt) {
                          setState(() {
                            matchedImages.add(img);
                            matchedTexts.add(txt);

                            if (matchedImages.length == finalMatchQuestions[questionIndex]['correctPairs'].length) {
                              isCorrectAnswer = true;
                              answerIndex = 1;
                              check = true;
                              score += widget.quiz ? questionPoints * 2 : questionPoints;
                            }
                          });
                        },
                        next: _next,
                        generalService: generalService,
                      ),
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