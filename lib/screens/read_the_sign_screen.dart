import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/badge_class.dart';
import '../classes/question_class.dart';
import '../classes/user_class.dart';
import '../components/completed_lesson_widget.dart';
import '../components/read_the_sign_widget.dart';
import '../services/general_service.dart';
import '../services/user_service.dart';

class ReadTheSignScreen extends StatefulWidget {
  const ReadTheSignScreen({super.key, required this.title, required this.multipleChoiceQuestions, required this.username, required this.quiz, required this.timer, this.difficulty, required this.symbols,});

  final String title;
  final List<Question> multipleChoiceQuestions;
  final String username;
  final bool quiz;
  final bool timer;
  final String? difficulty;
  final bool symbols;

  @override
  State<ReadTheSignScreen> createState() => _ReadTheSignScreenState();
}

class _ReadTheSignScreenState extends State<ReadTheSignScreen> {
  final GeneralService generalService = GeneralService();
  final UserService userService = UserService();
  late UserClass? user;

  List<Question> finalMultipleChoiceQuestions = [];
  List<String> possibleAnswers = [];
  List<BadgeClass> badges = [];
  String? answer;

  int? answerIndex;
  int questionIndex = 0;
  int score = 0;
  late int newScore = 0;
  final int pointsMCQ = 10;
  int difference = 0;

  bool completed = false;
  bool isCorrectAnswer = false;
  bool check = false;
  bool timerEnd = false;
  bool newBadge = false;
  bool darkMode = false;

  late DateTime endTime;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _createPossibleAnswersMCQ() async {
    if (finalMultipleChoiceQuestions.isEmpty) return;

    final String correctWord = finalMultipleChoiceQuestions[questionIndex].answer;

    List<Question> allMCQ = [];
    if (widget.symbols) {
      allMCQ = await generalService.loadMCQSignToWords();
    } else {
      allMCQ = await generalService.loadMCQ();
    }

    List<String> wrongWords = allMCQ
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
    List<int> dbBadges = List<int>.from(user!.badges);

    if (!timerEnd) {
      difference = await generalService.complete(widget.username, score);
      user = await userService.refreshUserLocalStorage();
    }

    int dbTrainCount;
    int dbQuizCount;
    if (widget.title == "Signs to Words") {
      dbTrainCount = user!.signToWordsTCount + 1;
      dbQuizCount = user!.signToWordsQCount + 1;
    } else {
      dbTrainCount = user!.readTheSignTCount + 1;
      dbQuizCount = user!.readTheSignQCount + 1;
    }

    newScore = score;
    final badgesSnapshot = await FirebaseDatabase.instance
        .ref()
        .child('badges')
        .get();

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
            newBadge = true;
          }
        }

        if (widget.title == "Sign to Words") {
          if (widget.quiz) {
            if (data['signToWordsQCount'] == dbQuizCount) {
              int badgeNum = data['badgeNum'] as int;

              if (!dbBadges.contains(badgeNum)) {
                dbBadges.add(badgeNum);
                badges.add(BadgeClass.fromMap(data));
                newBadge = true;
              }
            }
          } else {
            if (data['signToWordsTCount'] == dbTrainCount) {
              int badgeNum = data['badgeNum'] as int;

              if (!dbBadges.contains(badgeNum)) {
                dbBadges.add(badgeNum);
                badges.add(BadgeClass.fromMap(data));
                newBadge = true;
              }
            }
          }
        } else {
          if (widget.quiz) {
            if (data['readTheSignQCount'] == dbQuizCount) {
              int badgeNum = data['badgeNum'] as int;

              if (!dbBadges.contains(badgeNum)) {
                dbBadges.add(badgeNum);
                badges.add(BadgeClass.fromMap(data));
                newBadge = true;
              }
            }
          } else {
            if (data['readTheSignTCount'] == dbTrainCount) {
              int badgeNum = data['badgeNum'] as int;

              if (!dbBadges.contains(badgeNum)) {
                dbBadges.add(badgeNum);
                badges.add(BadgeClass.fromMap(data));
                newBadge = true;
              }
            }
          }
        }
      }
    }

    final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
    final userRef = usersRef.child(widget.username);

    if (widget.title == "Sign to Words") {
      if (widget.quiz) {
        await userRef.update({
          'learningDetails/score': user!.score + newScore,
          'learningDetails/badges': dbBadges,
          'learningDetails/trainCounts/signToWordsQCount': dbQuizCount,
        });
      } else {
        await userRef.update({
          'learningDetails/score': user!.score + newScore,
          'learningDetails/badges': dbBadges,
          'learningDetails/trainCounts/signToWordsTCount': dbTrainCount,
        });
      }
    } else {
      if (widget.quiz) {
        await userRef.update({
          'learningDetails/score': user!.score + newScore,
          'learningDetails/badges': dbBadges,
          'learningDetails/quizCounts/readTheSignQCount': dbQuizCount,
        });
      } else {
        await userRef.update({
          'learningDetails/score': user!.score + newScore,
          'learningDetails/badges': dbBadges,
          'learningDetails/trainCounts/readTheSignTCount': dbTrainCount,
        });
      }
    }

    user = await userService.refreshUserLocalStorage();

    setState(() {
      completed = true;
      isCorrectAnswer = false;
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
          score += widget.quiz ? pointsMCQ * 2 : pointsMCQ;
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

  // Function to load username from local storage, when already logged in.
  Future<void> _loadUserLocalStorage() async {
    user = await userService.loadUserLocalStorage();

    if (user != null) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    _loadTheme();
    _loadUserLocalStorage().then((_) async {
      endTime = generalService.calculateEndTime(widget.multipleChoiceQuestions.length, widget.difficulty);
      finalMultipleChoiceQuestions = List<Question>.from(widget.multipleChoiceQuestions)..shuffle();
      _createPossibleAnswersMCQ();
    });
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

        if (widget.quiz) {
          generalService.exitPrompt(context, 'quiz');
        } else {
          generalService.exitPrompt(context, 'training');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: darkMode
                    ? [Colors.grey.shade900, Colors.black]
                    : [Colors.orange.shade500, Colors.deepOrange.shade800],
              ),
            ),
          ),
          title: Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
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
                        newBadge: newBadge,
                        score: score,
                        reviewLesson: false,
                        isGuest: false,
                        timerEnd: timerEnd,
                        quiz: widget.quiz,
                        darkMode: darkMode,
                        streak: user?.streakNum,
                        streakUpdate: difference == 1 ? true : false,
                      ) : ReadTheSignQuestion(
                        question: finalMultipleChoiceQuestions[questionIndex],
                        possibleAnswers: possibleAnswers,
                        pointsMCQ: widget.quiz ? pointsMCQ * 2 : pointsMCQ,
                        answerIndex: answerIndex,
                        isCorrectAnswer: isCorrectAnswer,
                        check: check,
                        darkMode: darkMode,
                        onTap: (index) {
                          if (!check) {
                            setState(() {
                              answerIndex = index;
                            });
                          }
                        },
                        next: _next,
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