import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/lesson_class.dart';
import '../classes/question_class.dart';
import '../classes/quiz_class.dart';
import '../classes/reading_tutorial_class.dart';

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

  List<ReadingTutorial> readingTutorials = [];
  List<Question> multipleChoiceQuestions = [];
  List<Question> signToTextQuestions = [];
  List<Map<String, dynamic>> matchQuestions = [];
  Quiz? quiz;
  List<String> possibleAnswers = [];
  List<String> options = [];
  Set<String> matchedImages = {};
  Set<String> matchedTexts = {};

  String? answer;

  int? answerIndex;
  int tutorialIndex = 0;

  bool tutorial = true;
  bool isQuiz = false;
  bool quizAnimation = false;

  void _snackBar(String text, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _quiz() async {
    setState(() {
      quizAnimation = true;
    });

    await Future.delayed(const Duration(seconds: 4));

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

  void _createOptions() {
    final lessonNum = widget.lesson.lessonNum;

    if (lessonNum == 1) {
      options = ['A', 'B', 'C', 'D', 'E'];
    } else if (lessonNum == 2) {
      options = ['F', 'G', 'H', 'I', 'J'];
    } else if (lessonNum == 3) {
      options = ['K', 'L', 'M', 'N', 'O'];
    } else if (lessonNum == 4) {
      options = ['P', 'Q', 'R', 'S', 'T'];
    } else if (lessonNum == 5) {
      options = ['U', 'V', 'W', 'X', 'Y', 'Z'];
    } else if (lessonNum == 6) {
      options = ['1', '2', '3', '4', '5'];
    } else if (lessonNum == 7) {
      options = ['6', '7', '8', '9', '10'];
    }
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

  void _createPossibleAnswers() {
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
        _createPossibleAnswers();
      });
      return;
    }

    if (isQuiz && quiz != null) {
      // Check of match question.
      final currentQuestion = quiz!.question;

      if (quiz!.isMatch) {
        if (matchedImages.length < 3) {
          _snackBar('You should match all images to text!', Colors.grey.shade600);
          return;
        }
      } else {
        // Check of signToText question.
        if (answerIndex == null) {
          _snackBar('You should select an answer!', Colors.grey.shade600);
          return;
        }

        final question = currentQuestion as Question;
        if (options[answerIndex!] != question.answer) {
          _snackBar('Incorrect answer. Try again!', Colors.red.shade400);

          setState(() {
            answerIndex = null;
          });
          return;
        } else {
          _snackBar('Correct answer!', Colors.green.shade400);
        }
      }

      if (!quiz!.isCompleted) {
        setState(() {
          quiz!.next();
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

          Navigator.pop(context);
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

        if (widget.lesson.lessonNum > dbCompletedLessons) {
          await userRef.update({
            'learningDetails': {
              'streakNum': dbStreakNum,
              'streakNumGoal': dbStreakNumGoal,
              'score': dbScore + 10,
              'completedLessons': dbCompletedLessons + 1,
            }
          });
        }

        Navigator.pop(context);
      }
      return;
    }

    // Check of multipleChoice question.
    if (answerIndex == null) {
      _snackBar('You should select an answer!', Colors.grey.shade600);
      return;
    }

    final correctAnswer = multipleChoiceQuestions[tutorialIndex].answer;

    if (possibleAnswers[answerIndex!] != correctAnswer) {
      _snackBar('Incorrect answer. Try again!', Colors.red.shade400);

      setState(() {
        answerIndex = null;
      });
      return;
    } else {
      _snackBar('Correct answer!', Colors.green.shade400);
    }

    if (tutorialIndex < readingTutorials.length - 1) {
      setState(() {
        tutorial = true;
        tutorialIndex++;
      });
    } else {
      _quiz();
    }
  }

  void _previous() {
    setState(() {
      answerIndex = null;

      if (!tutorial) {
        tutorial = true;
      } else if (tutorialIndex > 0) {
        tutorial = false;
        tutorialIndex--;

        _createPossibleAnswers();
      } else {
        _snackBar('There is no previous content!', Colors.grey.shade600);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _loadReadingTutorials();
    _loadQuestions();
    _createOptions();
    _createMatchQuestions();
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
              return AlertDialog(
                title: const Text('Are you sure you want to exit this lesson?'),
                content: const Text(
                  "Your progress in this lesson will not be saved until you finish.",
                  style: TextStyle(fontSize: 18.0),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
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
                  TextButton(
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
                  color: Colors.black,
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
                    child: isQuiz ? _buildQuiz() : _buildTutorial(),
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
                duration: 4000,
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

  Widget _buildQuiz() {
    final currentQuestion = quiz!.question;
    return quiz!.isMatch ? _matchQuestion(
        currentQuestion as Map<String, dynamic>) : _signToTextQuestion(
        currentQuestion as Question);
  }

  Widget _matchQuestion(Map<String, dynamic> matchQuestions) {
    return Column(
      children: [
        const SizedBox(height: 5.0),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            border: Border.all(width: 2.0, color: Colors.orange.shade300),
            borderRadius: BorderRadius.circular(15.0),
          ),
          alignment: Alignment.center,
          child: Text(
            'Drag each image onto its correct meaning:',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 25.0),
        Column(
          children: List.generate(
            matchQuestions['shuffledPairs'].length, (index) {
            final img = matchQuestions['correctPairs'][index]['image'];
            final txt = matchQuestions['shuffledPairs'][index]['text'];

            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: matchedImages.contains(img) ? Icon(
                      Icons.check_circle,
                      color: Colors.green.shade400,
                      size: 60.0
                    ) : Draggable<Map<String, String>>(
                      data: {
                        'image': img,
                        'text': txt,
                      },
                      feedback: Opacity(
                        opacity: 0.7,
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.0),
                            border: Border.all(
                              width: 2.0,
                              color: Colors.orange.shade100,
                            ),
                          ),
                          child: Image.asset(
                            img,
                            height: 110,
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.0),
                            border: Border.all(
                              width: 2.0,
                              color: Colors.orange.shade100,
                            ),
                          ),
                          child: Image.asset(
                            img,
                            height: 110,
                          ),
                        )
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0),
                          border: Border.all(
                            width: 2.0,
                            color: Colors.orange.shade100,
                          ),
                        ),
                        child: Image.asset(
                          img,
                          height: 110,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 25.0),
                  Expanded(
                    child: matchedTexts.contains(txt) ? Container(
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        txt,
                        style: const TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)
                      ),
                    ) : DragTarget<Map<String, String>>(
                      onWillAcceptWithDetails: (_) => true,
                      onAcceptWithDetails: (details) {
                        final correctText = details.data['image']!
                            .split('/').last
                            .replaceAll('.png', '')
                            .toUpperCase();

                        if (correctText == txt) {
                          setState(() {
                            matchedImages.add(details.data['image']!);
                            matchedTexts.add(txt);
                          });

                          _snackBar('Correct answer!', Colors.green.shade400);
                        } else {
                          _snackBar('Incorrect answer. Try again!', Colors.red.shade400);
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        bool isHovering = candidateData.isNotEmpty;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 70.0,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isHovering ? Colors.orange.shade100 : Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: isHovering ? Colors.orange.shade700 : Colors.orange.shade200,
                              width: 2.5,
                            ),
                          ),
                          child: Text(
                            txt,
                            style: const TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
          ),
        ),
        const SizedBox(height: 25.0),
        _navigationButtons(),
      ],
    );
  }

  Widget _signToTextQuestion(Question q) {
    return Column(
      children: [
        const SizedBox(height: 5.0),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            border: Border.all(width: 2.0, color: Colors.orange.shade300),
            borderRadius: BorderRadius.circular(15.0),
          ),
          alignment: Alignment.center,
          child: Text(
            q.question,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 30.0),
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [BoxShadow(
              color: Colors.orange,
              blurRadius: 2.0,
              offset: Offset(0.5, 0.5),
            )],
          ),
          child: Image.asset(
            q.questionContent,
            height: 300,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 25.0),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: 2.0,
          children: List.generate(options.length, (index) {
            final selected = answerIndex == index;

            return InkWell(
              onTap: () {
                setState(() {
                  answerIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? Colors.orange.shade100 : Colors.white,
                  border: Border.all(
                    color: selected ? Colors.orange.shade700 : Colors.orange.shade200,                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  options[index],
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 25.0),
        _navigationButtons(),
      ],
    );
  }

  Widget _multipleChoiceQuestion() {
    return Column(
      children: [
        CircleAvatar(
          radius: 32.0,
          backgroundColor: Colors.orange.shade700,
          child: Text(
            multipleChoiceQuestions[tutorialIndex].questionContent,
            style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 5.0),
        Column(
          children: List.generate(3, (index) {
            final selected = answerIndex == index;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    answerIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: selected ? Colors.orange.shade100 : Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(
                      color: selected ? Colors.orange.shade700 : Colors.orange.shade200,
                      width: selected ? 3.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: selected ? Colors.orange.shade700 : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 30.0),
                      Image.asset(
                        possibleAnswers[index],
                        height: 110,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTutorial() {
    return Column(
      children: [
        const SizedBox(height: 5.0),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            border: Border.all(width: 2.0, color: Colors.orange.shade300),
            borderRadius: BorderRadius.circular(15.0),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.lesson.name,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 15.0),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 2.0, color: Colors.orange.shade300),
            borderRadius: BorderRadius.circular(15.0),
          ),
          alignment: Alignment.center,
          child: Text(
            tutorial
                ? readingTutorials[tutorialIndex].tutorialText
                : multipleChoiceQuestions[tutorialIndex].question,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        if(tutorial) ...[
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [BoxShadow(
                color: Colors.orange,
                blurRadius: 2.0,
                offset: Offset(0.5, 0.5),
              )],
            ),
            child: Image.asset(
              readingTutorials[tutorialIndex].tutorialImage,
              height: 300,
              fit: BoxFit.contain,
            ),
          ),
        ] else ...[
          _multipleChoiceQuestion(),
        ],
        const SizedBox(height: 15.0),
        _navigationButtons(),
      ],
    );
  }

  Widget _navigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 2.0, color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Row(
        mainAxisAlignment: !isQuiz ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
        children: [
          if (!isQuiz) ...[
            TextButton(
              onPressed: _previous,
              child: Text(
                'Previous',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ),
          ],
          ElevatedButton(
            onPressed: _next,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
            child: const Text(
              'Next',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}