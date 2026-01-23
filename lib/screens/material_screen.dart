import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/services/general_service.dart';

import '../classes/badge_class.dart';
import '../classes/lesson_class.dart';
import '../classes/question_class.dart';
import '../classes/quiz_class.dart';
import '../classes/reading_tutorial_class.dart';
import '../components/build_quiz_widget.dart';
import '../components/build_tutorial_widget.dart';
import '../components/completed_lesson_widget.dart';

class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key, required this.lesson, required this.username});

  final Lesson lesson;
  final String username;

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  // Stack Overflow. (n.d.). How to generate a list of all alphabets (UpperCase) in dart? [online]
  // Available at: https://stackoverflow.com/questions/67897675/how-to-generate-a-list-of-all-alphabets-uppercase-in-dart
  // [Accessed 19 Dec. 2025].
  final List<String> images = [
    ...List.generate(
        26, (i) => 'assets/images/${String.fromCharCode(65 + i)}.png'),
    ...List.generate(10, (i) => 'assets/images/${i + 1}.png'),
  ];
  final GeneralService generalService = GeneralService();

  List<ReadingTutorial> readingTutorials = [];
  List<Question> multipleChoiceQuestions = [];
  List<Question> signToTextQuestions = [];
  List<Map<String, dynamic>> matchQuestions = [];
  Quiz? quiz;
  List<String> possibleAnswers = [];
  List<String> options = [];
  Set<String> matchedImages = {};
  Set<String> matchedTexts = {};
  List<BadgeClass> badges = [];
  String? answer;

  int? answerIndex;
  int tutorialIndex = 0;

  bool tutorial = true;
  bool isQuiz = false;
  bool quizAnimation = false;
  bool completed = false;
  bool isCorrectAnswer = false;

  void _quiz() async {
    setState(() {
      quizAnimation = true;
    });

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      quizAnimation = false;
      isQuiz = true;
      quiz = Quiz(
        signToTextQuestions: signToTextQuestions,
        matchQuestions: matchQuestions,
      );

      answerIndex = null;
      matchedImages.clear();
      matchedTexts.clear();
    });
  }

  void _createMatchQuestions() {
    final lessonNum = widget.lesson.lessonNum;
    int signs = 0;

    if (lessonNum == 1) {
      signs = 5;
    }
    else if (lessonNum == 2) {
      signs = 10;
    }
    else if (lessonNum == 3) {
      signs = 15;
    }
    else if (lessonNum == 4) {
      signs = 20;
    }
    else if (lessonNum == 5) {
      signs = 26;
    }
    else if (lessonNum == 6) {
      signs = 31;
    }
    else if (lessonNum == 7) {
      signs = 36;
    }

    final imgs = images.take(signs).toList();
    matchQuestions.clear();

    for (int i = 0; i < 3; i++) {
      final shuffledImages = List<String>.from(imgs)
        ..shuffle();
      final matchImages = shuffledImages.take(3).toList();

      final correctPairs = matchImages.map((img) {
        return {
          'image': img,
          'text': img
              .split('/')
              .last
              .replaceAll('.png', ''),
        };
      }).toList();

      final shuffledPairs = List<Map<String, String>>.from(correctPairs)
        ..shuffle();

      matchQuestions.add({
        'correctPairs': correctPairs,
        'shuffledPairs': shuffledPairs,
      });
    }
  }

  void _createPossibleAnswersMCQ() {
    final correctImage = multipleChoiceQuestions[tutorialIndex].answer;

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

  Future<void> _loadReadingTutorials() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('readingTutorials').get();
    if (!snapshot.exists || snapshot.value == null) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    readingTutorials = data.values
        .map((value) =>
        ReadingTutorial.fromMap(Map<String, dynamic>.from(value as Map)))
        .where((tut) => tut.lessonNum == widget.lesson.lessonNum)
        .toList();

    readingTutorials.sort((a, b) =>
        a.readingTutorial.compareTo(b.readingTutorial));
    setState(() {});
  }

  Future<void> _loadQuestions() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('questions').get();
    if (!snapshot.exists || snapshot.value == null) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    List<Question> allQuestions = data.values
        .map((value) =>
        Question.fromMap(Map<String, dynamic>.from(value as Map)))
        .where((q) => q.lessonNum == widget.lesson.lessonNum)
        .toList();

    setState(() {
      multipleChoiceQuestions = allQuestions
          .where((q) => q.questionType == QuestionType.multipleChoice)
          .toList()
        ..sort((a, b) => a.questionNum.compareTo(b.questionNum));

      signToTextQuestions = allQuestions
          .where((q) => q.questionType == QuestionType.text)
          .toList()
        ..sort((a, b) => a.questionNum.compareTo(b.questionNum));
    });
  }

  void _next() async {
    // Check of readingTutorial.
    if (tutorial) {
      setState(() {
        tutorial = false;
        isCorrectAnswer = false;
        _createPossibleAnswersMCQ();
      });
      return;
    }

    if (isQuiz && quiz != null) {
      // Check of match question.
      final currentQuestion = quiz!.question;

      if (quiz!.isMatch) {
        if (matchedImages.length < 3) {
          generalService.snackBar(context, 'You should match all images to text!', Colors.grey.shade600);
          return;
        }
      } else {
        // Check of signToText question.
        if (answerIndex == null) {
          generalService.snackBar(context, 'You should select an answer!', Colors.grey.shade600);
          return;
        }

        final question = currentQuestion as Question;
        if (options[answerIndex!] != question.answer) {
          setState(() {
            isCorrectAnswer = false;
          });
        } else {
          if (!isCorrectAnswer) {
            setState(() {
              isCorrectAnswer = true;
            });
            return;
          }
        }
      }

      if (!quiz!.isCompleted) {
        setState(() {
          quiz!.next();
          isCorrectAnswer = false;
          answerIndex = null;
          matchedImages.clear();
          matchedTexts.clear();
        });
      } else {
        if (widget.username.isEmpty) {
          final prefs = await SharedPreferences.getInstance();
          int guestCompletedLessons = prefs.getInt('guestCompletedLessons') ?? 0;

          if (widget.lesson.lessonNum > guestCompletedLessons) {
            await prefs.setInt('guestCompletedLessons', widget.lesson.lessonNum);
          }

          setState(() {
            completed = true;
          });
          return;
        }

        final DatabaseReference usersRef = FirebaseDatabase.instance
            .ref()
            .child('users');
        final DatabaseReference userRef = usersRef.child(widget.username);
        final DataSnapshot snapshot = await userRef.get();

        int dbStreakNum = snapshot
            .child('learningDetails/streakNum')
            .value as int;
        int dbStreakNumGoal = snapshot
            .child('learningDetails/streakNumGoal')
            .value as int;
        int dbScore = snapshot
            .child('learningDetails/score')
            .value as int;
        int dbCompletedLessons = snapshot
            .child('learningDetails/completedLessons')
            .value as int;

        List<int> dbBadges = [];
        if (snapshot.child('learningDetails/badges').exists) {
          dbBadges = List<int>.from(snapshot.child('learningDetails/badges').value as List);
        }

        if (widget.lesson.lessonNum > dbCompletedLessons) {
          final badgesSnapshot = await FirebaseDatabase.instance.ref().child('badges').get();

          if (badgesSnapshot.exists) {
            final Map<dynamic, dynamic> badges = badgesSnapshot.value as Map;

            for (var entry in badges.entries) {
              final data = Map<String, dynamic>.from(entry.value as Map);

              if (data['lessonNum'] == widget.lesson.lessonNum) {
                int badgeNum = data['badgeNum'] as int;

                if (!dbBadges.contains(badgeNum)) {
                  dbBadges.add(badgeNum);
                }
              }
            }
          }

          await userRef.update({
            'learningDetails': {
              'streakNum': dbStreakNum,
              'streakNumGoal': dbStreakNumGoal,
              'score': dbScore + 10,
              'completedLessons': dbCompletedLessons + 1,
              'badges': dbBadges,
            }
          });
        }

        setState(() {
          completed = true;
          isCorrectAnswer = false;
        });
      }
      return;
    }

    // Check of multipleChoice question.
    if (answerIndex == null) {
      generalService.snackBar(context, 'You should select an answer!', Colors.grey.shade600);
      return;
    }

    final correctAnswer = multipleChoiceQuestions[tutorialIndex].answer;

    if (possibleAnswers[answerIndex!] != correctAnswer) {
      setState(() {
        isCorrectAnswer = false;
      });
    } else {
      if (!isCorrectAnswer) {
        setState(() {
          isCorrectAnswer = true;
        });
        return;
      }
    }

    if (tutorialIndex < readingTutorials.length - 1) {
      setState(() {
        isCorrectAnswer = false;
        answerIndex = null;
        tutorial = true;
        tutorialIndex++;
      });
    } else {
      setState(() {
        isCorrectAnswer = false;
        answerIndex = null;
      });

      _quiz();
    }
  }

  Future<void> _loadBadges() async {
    badges = await generalService.loadBadges();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _loadReadingTutorials();
    _loadQuestions();
    options = generalService.createOptions(widget.lesson.lessonNum);
    _createMatchQuestions();
    _loadBadges();
  }

  @override
  Widget build(BuildContext context) {
    int totalTutorials = readingTutorials.length * 2;
    int totalQuizQuestions = signToTextQuestions.length + matchQuestions.length;
    int total = totalTutorials + totalQuizQuestions;
    int index = 0;

    if (total > 0) {
      if (!isQuiz) {
        index = (tutorialIndex * 2) + (tutorial ? 1 : 2);
      } else if (quiz != null) {
        index = totalTutorials + (quiz!.questionIndex + 1);
      }
    }

    double progress = total > 0 ? (index / total).clamp(0.0, 1.0) : 0.0;

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
                      'Are you sure you want to exit this lesson?',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      "Your progress in this lesson will not be saved until you finish.",
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
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.orange.shade50,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.orange.shade500, Colors.deepOrange.shade800]),
                ),
              ),
              title: Text(
                "Lesson ${widget.lesson.lessonNum}",
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
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: readingTutorials.isEmpty ? const Center(
                    child: CircularProgressIndicator()) : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: completed
                      ? CompletedLesson(
                        lessonNum: widget.lesson.lessonNum,
                        completed: () => Navigator.pop(context),
                        badges: badges,
                      ) : (isQuiz
                        ? BuildQuiz(
                          quiz: quiz!,
                          matchedImages: matchedImages,
                          matchedTexts: matchedTexts,
                          answerIndex: answerIndex,
                          isCorrectAnswer: isCorrectAnswer,
                          options: options,
                          generalService: generalService,
                          next: _next,
                          onMatch: (img, txt) {
                            setState(() {
                              matchedImages.add(img);
                              matchedTexts.add(txt);
                            });
                          },
                          onTap: (index) {
                            setState(() {
                              answerIndex = index;
                              isCorrectAnswer = (options[index] == quiz!.question.answer);
                            });
                          },
                        )
                        : BuildTutorial(
                        lesson: widget.lesson,
                        tutorial: tutorial,
                        readingTutorials: readingTutorials,
                        multipleChoiceQuestions: multipleChoiceQuestions,
                        tutorialIndex: tutorialIndex,
                        possibleAnswers: possibleAnswers,
                        answerIndex: answerIndex,
                        isCorrectAnswer: isCorrectAnswer,
                        onTap: (index) {
                          setState(() {
                            answerIndex = index;
                            isCorrectAnswer = (possibleAnswers[index] == multipleChoiceQuestions[tutorialIndex].answer);
                          });
                        },
                        next: _next,
                      )
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Dart packages. (2020). animated_splash_screen. [online]
          // Available at: https://pub.dev/packages/animated_splash_screen
          // [Accessed 16 Jan. 2026].
          if (quizAnimation) ...[
            Positioned.fill(
              child: AnimatedSplashScreen(
                duration: 3000,
                splashIconSize: 250,
                splash: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      color: Colors.orange.shade900,
                      size: 80,
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      "Time for a quiz!",
                      style: TextStyle(
                        fontSize: 35.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Are you ready?",
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                nextScreen: Container(),
                splashTransition: SplashTransition.scaleTransition,
                backgroundColor: Colors.orange.shade50,
              ),
            ),
          ],
        ],
      ),
    );
  }
}