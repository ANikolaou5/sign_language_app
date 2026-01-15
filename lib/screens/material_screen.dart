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

  void _quiz() {
    setState(() {
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
    if (tutorial) {
      setState(() {
        tutorial = false;
        _createPossibleAnswers();
      });
      return;
    }

    if (isQuiz && quiz != null) {
      final currentQuestion = quiz!.question;

      if (quiz!.isMatch) {
        if (matchedImages.length < 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You should match all images and text!'),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }
      } else {
        if (answerIndex == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You should select an answer!'),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }

        final question = currentQuestion as Question;
        if (options[answerIndex!] != question.answer) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Incorrect answer. Try again!',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.red.shade400,
              duration: Duration(seconds: 1),
            ),
          );

          setState(() {
            answerIndex = null;
          });
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Correct answer!',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.green.shade400,
              duration: Duration(seconds: 1),
            ),
          );
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

    if (answerIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You should select an answer!'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final correctAnswer = multipleChoiceQuestions[tutorialIndex].answer;

    if (possibleAnswers[answerIndex!] != correctAnswer) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Incorrect answer. Try again!',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red.shade400,
          duration: Duration(seconds: 1),
        ),
      );

      setState(() {
        answerIndex = null;
      });
      return;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Correct answer!',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.green.shade400,
          duration: Duration(seconds: 1),
        ),
      );
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
    if (!tutorial) {
      setState(() {
        tutorial = true;
      });
    } else if (tutorialIndex > 0) {
      setState(() {
        tutorial = false;
        tutorialIndex--;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('There is no previous content!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
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
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }, child: const Text('Yes')),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    }, child: const Text('No'),
                  ),
                ],
              );
            }
        );
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme
              .of(context)
              .colorScheme
              .inversePrimary,
          title: Text(
            "Lesson ${widget.lesson.lessonNum}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: readingTutorials.isEmpty ? const Center(
              child: CircularProgressIndicator()) : SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: isQuiz ? _buildQuiz() : _buildTutorial(),
          ),
        ),
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
              color: Colors.purple.shade100,
              border: Border.all(),
            ),
            alignment: Alignment.center,
            child: Text(
              'Time for a quiz!',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            )
        ),
        const SizedBox(height: 15.0),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.purple.shade100,
            border: Border.all(),
          ),
          alignment: Alignment.center,
          child: Text(
            'Drag each image onto its correct meaning:',
            style: const TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 30.0),
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
                    child: matchedImages.contains(img) ? const SizedBox(
                        height: 120.0) : Draggable<Map<String, String>>(
                      data: {
                        'image': img,
                        'text': txt,
                      },
                      feedback: Opacity(
                        opacity: 0.7,
                        child: Image.asset(
                          img,
                          width: 120,
                        ),
                      ),
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Image.asset(
                          img,
                          width: 120,
                          height: 120,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 30.0),
                  Expanded(
                    child: matchedTexts.contains(txt) ? const SizedBox(
                        height: 60.0) : DragTarget<Map<String, String>>(
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

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Correct answer!',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Colors.green.shade400,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Incorrect answer. Try again!',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Colors.red.shade400,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        bool isHovering = candidateData.isNotEmpty;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 80.0,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isHovering ? Colors.indigo.shade200 : Colors
                                .white,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: isHovering ? Colors.indigo : Colors.grey
                                  .shade400,
                              width: 2.5,
                            ),
                            boxShadow: [
                              if (!isHovering)
                                BoxShadow(color: Colors.grey.shade300,
                                    spreadRadius: 1.0,
                                    blurRadius: 3.0),
                            ],
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
        const SizedBox(height: 15.0),
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
              color: Colors.purple.shade100,
              border: Border.all(),
            ),
            alignment: Alignment.center,
            child: Text(
              'Time for a quiz!',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            )
        ),
        const SizedBox(height: 15.0),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.purple.shade100,
            border: Border.all(),
          ),
          alignment: Alignment.center,
          child: Text(
            q.questionContent,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 30.0),
        Image.asset(
          q.questionContent,
          width: double.infinity,
          height: 400,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 30.0),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: 2.5,
          children: List.generate(options.length, (index) {
            final selected = answerIndex == index;

            return InkWell(
              onTap: () {
                setState(() {
                  answerIndex = index;
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selected ? Colors.green : Colors.grey,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                  color: selected ? Colors.green.shade100 : Colors.white,
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
        const SizedBox(height: 15.0),
        _navigationButtons(),
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
            color: Colors.purple.shade100,
            border: Border.all(),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.lesson.name,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 15.0),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.purple.shade100,
            border: Border.all(),
          ),
          alignment: Alignment.center,
          child: Text(
            tutorial
                ? readingTutorials[tutorialIndex].tutorialText
                : multipleChoiceQuestions[tutorialIndex].question,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if(tutorial) ...[
          const SizedBox(height: 15.0),
          Image.asset(
            readingTutorials[tutorialIndex].tutorialImage,
            width: double.infinity,
            height: 400,
            fit: BoxFit.contain,
          ),
        ] else
          ...[
            const SizedBox(height: 15.0),
            Container(
              padding: const EdgeInsets.all(8.0),
              width: 70.0,
              height: 60.0,
              decoration: BoxDecoration(
                color: Colors.green.shade300,
                border: Border.all(),
              ),
              alignment: Alignment.center,
              child: Text(
                multipleChoiceQuestions[tutorialIndex].questionContent,
                style: TextStyle(
                  fontSize: 25.0,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${index + 1}.',
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 15.0),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selected ? Colors.green : Colors.grey,
                              width: selected ? 3.0 : 2.0,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            possibleAnswers[index],
                            height: 130.0,
                            width: 130.0,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        const SizedBox(height: 15.0),
        _navigationButtons(),
      ],
    );
  }

  Widget _navigationButtons() {
    return Row(
      mainAxisAlignment: !isQuiz ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
      children: [
        if (!isQuiz) ...[
          ElevatedButton(
            onPressed: _previous,
            child: const Text(
              'Previous',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black
              ),
            ),
          ),
        ],
        ElevatedButton(
          onPressed: _next,
          child: const Text(
            'Next',
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.black
            ),
          ),
        ),
      ],
    );
  }
}