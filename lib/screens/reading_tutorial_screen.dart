import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/classes/reading_tutorial_class.dart';

import '../classes/badge_class.dart';
import '../classes/question_class.dart';
import '../classes/user_class.dart';
import '../components/build_tutorial_widget.dart';
import '../components/completed_lesson_widget.dart';
import '../services/general_service.dart';
import '../services/user_service.dart';

class ReadingTutorialScreen extends StatefulWidget {
  const ReadingTutorialScreen({super.key, required this.readingTutorial, required this.username});

  final ReadingTutorial readingTutorial;
  final String? username;

  @override
  State<ReadingTutorialScreen> createState() => _ReadingTutorialScreenState();
}

class _ReadingTutorialScreenState extends State<ReadingTutorialScreen> {
  final List<String> images = [
    ...List.generate(
        26, (i) => 'assets/images/${String.fromCharCode(65 + i)}.png'),
    ...List.generate(10, (i) => 'assets/images/${i + 1}.png'),
  ];

  final GeneralService generalService = GeneralService();
  final UserService userService = UserService();

  Question? multipleChoiceQuestion;
  List<String> possibleAnswers = [];
  List<BadgeClass> badges = [];
  String? answer;

  int? answerIndex;
  int tutorialIndex = 0;
  int score = 0;
  final int pointsMCQ = 10;

  bool tutorial = true;
  bool completed = false;
  bool isCorrectAnswer = false;
  bool reviewLesson = false;
  bool isGuest = false;
  bool check = false;

  void _createPossibleAnswersMCQ() {
    final correctImage = multipleChoiceQuestion!.answer;

    final wrongImages = images
        .where((img) => img != correctImage)
        .toList()
      ..shuffle();

    possibleAnswers = [
      correctImage,
      wrongImages[0],
      wrongImages[1],
    ]
      ..shuffle();

    answerIndex = null;
  }

  Future<void> _loadQuestions() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('questions').get();
    if (!snapshot.exists) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    final allQuestions = data.values.map((value) =>
        Question.fromMap(Map<String, dynamic>.from(value as Map))
    );

    setState(() {
      multipleChoiceQuestion = allQuestions.firstWhere(
        (q) => q.levelNum == widget.readingTutorial.levelNum &&
        q.questionType == QuestionType.multipleChoice &&
        q.questionNum == widget.readingTutorial.readingTutorial
      );


    });
  }

  Future<void> _complete() async {
    if (widget.username == null || widget.username!.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      List<String> guestCompletedLessons = prefs.getStringList('guestCompletedLessons') ?? [];

      if (!guestCompletedLessons.contains(widget.readingTutorial.readingTutorial.toString())) {
        guestCompletedLessons.add(widget.readingTutorial.readingTutorial.toString());
        await prefs.setStringList('guestCompletedLessons', guestCompletedLessons);
      }

      setState(() {
        completed = true;
        isGuest = true;
      });
      return;
    }

    final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
    final userRef = usersRef.child(widget.username!);
    final DataSnapshot snapshot = await userRef.get();
    UserClass user = UserClass.fromFirebase(widget.username!, Map<String, dynamic>.from(snapshot.value as Map));

    List<int> dbCompletedLessons = List<int>.from(user.completedLessons);

    if (dbCompletedLessons.contains(widget.readingTutorial.readingTutorial)) {
      setState(() {
        reviewLesson = true;
      });
    } else {
      int levels = user.completedLevels;
      dbCompletedLessons.add(widget.readingTutorial.readingTutorial);
      List<int> dbBadges = List<int>.from(user.badges);
      final badgesSnapshot = await FirebaseDatabase.instance.ref().child('badges').get();

      if (badgesSnapshot.exists) {
        final Map<dynamic, dynamic> badgesMap = badgesSnapshot.value as Map;

        for (var entry in badgesMap.entries) {
          final data = Map<String, dynamic>.from(entry.value as Map);

          if (data['levelNum'] == widget.readingTutorial.levelNum && data['size'] == dbCompletedLessons.length) {
            int badgeNum = data['badgeNum'] as int;
            levels += 1;

            if (!dbBadges.contains(badgeNum)) {
              dbBadges.add(badgeNum);
              badges.add(BadgeClass.fromMap(data));
            }
          }
        }
      }

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
          'completedLevels': levels,
          'badges': dbBadges,
          'completedLessons': dbCompletedLessons,
        }
      });
    }

    setState(() {
      completed = true;
      isCorrectAnswer = false;
      userService.refreshUserLocalStorage();
    });
  }

  void _next() async {
    // Check of readingTutorial.
    if (tutorial) {
      if (multipleChoiceQuestion == null) {
        await _complete();
        return;
      }

      _createPossibleAnswersMCQ();
      setState(() {
        tutorial = false;
        answerIndex = null;
        check = false;
      });
      return;
    }

    // Check of multipleChoice question.
    if (answerIndex == null) {
      generalService.snackBar(context, 'You should select an answer!', Colors.grey.shade600);
      return;
    }

    if (!check) {
      final correctAnswer = multipleChoiceQuestion?.answer;

      setState(() {
        check = true;

        if (possibleAnswers[answerIndex!] != correctAnswer) {
          isCorrectAnswer = false;
        }
        else {
          isCorrectAnswer = true;
          score = pointsMCQ;
        }
      });
      return;
    }

    await _complete();
  }

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
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
                      'Are you sure you want to exit this reading tutorial?',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      "Your progress in this reading tutorial will not be saved until you finish.",
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
            "Reading Tutorials",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
              child: completed ? CompletedLesson(
                readingTutorial: widget.readingTutorial.readingTutorial,
                completed: () => Navigator.pop(context),
                badges: badges,
                score: score,
                reviewLesson: reviewLesson,
                isGuest: isGuest,
              )
              : BuildTutorial(
                tutorial: tutorial,
                readingTutorial: widget.readingTutorial,
                multipleChoiceQuestion: multipleChoiceQuestion,
                tutorialIndex: tutorialIndex,
                possibleAnswers: possibleAnswers,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}