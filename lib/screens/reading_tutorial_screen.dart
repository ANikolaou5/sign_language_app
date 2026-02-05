import 'dart:math';

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

  final List<String> convImages = [
    'assets/conv/goodMorning.png',
    'assets/conv/goodNight.png',
    'assets/conv/hello.png',
    'assets/conv/goodbye.png',
    'assets/conv/iAmFine.png',
    'assets/conv/seeYou.png',
    'assets/conv/thankYou.png',
  ];

  final List<String> animalImages = [
    'assets/animals/cat.png',
    'assets/animals/dog.png',
    'assets/animals/bunny.png',
    'assets/animals/fish.png',
    'assets/animals/bird.png',
    'assets/animals/cow.png',
    'assets/animals/pig.png',
    'assets/animals/goat.png',
    'assets/animals/duck.png',
    'assets/animals/pony.png',
    'assets/animals/fox.png',
    'assets/animals/wolf.png',
    'assets/animals/bear.png',
    'assets/animals/lion.png',
    'assets/animals/deer.png',
    'assets/animals/bee.png',
    'assets/animals/fly.png',
    'assets/animals/ant.png',
    'assets/animals/moth.png',
    'assets/animals/worm.png',
  ];

  final List<String> symbolImages = [
    'assets/symbols/goodbye.png',
    'assets/symbols/hello.png',
    'assets/symbols/iLoveYou.png',
    'assets/symbols/no.png',
    'assets/symbols/please.png',
    'assets/symbols/sorry.png',
    'assets/symbols/please.png',
    'assets/symbols/yes.png',
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
    List<String> imgs;

    if (widget.readingTutorial.levelNum == 1 || widget.readingTutorial.levelNum == 2) {
      imgs = images;
    } else if (widget.readingTutorial.levelNum == 3) {
      imgs = convImages;
    } else if (widget.readingTutorial.levelNum == 4) {
      imgs = animalImages;
    } else if (widget.readingTutorial.levelNum == 5) {
      imgs = symbolImages;
    } else {
      imgs = images;
    }

    final wrongImages = imgs
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
        (q.questionType == QuestionType.multipleChoice || q.questionType == QuestionType.multipleChoiceWordsToSign) &&
        q.questionNum == widget.readingTutorial.readingTutorial
      );
    });
  }

  Future<void> _complete() async {
    if (widget.username == null || widget.username!.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      List<String> guestCompletedLessons = prefs.getStringList('guestCompletedLessons') ?? [];

      if (guestCompletedLessons.contains(widget.readingTutorial.readingTutorial.toString())) {
        setState(() {
          reviewLesson = true;
        });
      } else {
        if (!guestCompletedLessons.contains(widget.readingTutorial.readingTutorial.toString())) {
          guestCompletedLessons.add(widget.readingTutorial.readingTutorial.toString());
          await prefs.setStringList('guestCompletedLessons', guestCompletedLessons);
        }
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

      await userRef.update({
        'learningDetails/score': user.score + score,
        'learningDetails/completedLevels': levels,
        'learningDetails/badges': dbBadges,
        'learningDetails/completedLessons': dbCompletedLessons,
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

        generalService.exitPrompt(context, 'reading tutorial');
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
              key: ValueKey(Random().nextInt(1000000).toString()),
              scrollDirection: Axis.vertical,
              child: Center(
                child: completed ? CompletedLesson(
                  readingTutorial: widget.readingTutorial.readingTutorial,
                  completed: () => Navigator.pop(context),
                  badges: badges,
                  score: score,
                  reviewLesson: reviewLesson,
                  isGuest: isGuest,
                  timerEnd: false,
                  quiz: false,
                  streak: null,
                  streakUpdate: false,
                )
                : BuildTutorial(
                  key: ValueKey(widget.readingTutorial.tutorialText),
                  tutorial: tutorial,
                  readingTutorial: widget.readingTutorial,
                  multipleChoiceQuestion: multipleChoiceQuestion,
                  tutorialIndex: tutorialIndex,
                  possibleAnswers: possibleAnswers,
                  answerIndex: answerIndex,
                  isCorrectAnswer: isCorrectAnswer,
                  check: check,
                  questionPoints: pointsMCQ,
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
      ),
    );
  }
}