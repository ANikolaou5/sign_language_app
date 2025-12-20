import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key, required this.lesson, required this.username});

  final Map<String, dynamic> lesson;
  final String username;

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  // Stack Overflow. (n.d.). How to generate a list of all alphabets (UpperCase) in dart? [online]
  // Available at: https://stackoverflow.com/questions/67897675/how-to-generate-a-list-of-all-alphabets-uppercase-in-dart
  // [Accessed 19 Dec. 2025].
  final List<String> images = [
    ...List.generate(26, (i) => 'assets/images/${String.fromCharCode(65 + i)}.png'),
    ...List.generate(10, (i) => 'assets/images/${i + 1}.png'),
  ];

  List<Map<String, dynamic>> readingTutorials = [];
  List<Map<String, dynamic>> multipleChoiceQuestions = [];
  List<Map<String, dynamic>> signToTextQuestions = [];
  List<Map<String, dynamic>> matchQuestions = [];
  Map<String, String> userMatch = {};
  List<String> possibleAnswers = [];

  late TextEditingController answerTextController;
  String? answer;
  String? matchImg;
  String? matchTxt;

  int? answerIndex;
  int tutorialIndex = 0;
  int signToText = 0;
  int matchIndex = 0;

  bool tutorial = true;
  bool quiz = false;

  void _createMatchQuestions() {
    final shuffledImages = List<String>.from(images)..shuffle();

    matchQuestions.clear();

    for (int i = 0; i < 3; i++) {
      final matchImages = shuffledImages.skip(i * 3).take(3).toList();

      final correctPairs = matchImages.map((img) {
        return {
          'image': img,
          'text': img.split('/').last.replaceAll('.png', ''),
        };
      }).toList();

      final shuffledPairs = List<Map<String, String>>.from(correctPairs)..shuffle();

      matchQuestions.add({
        'correctPairs': correctPairs,
        'shuffledPairs': shuffledPairs,
      });
    }
  }

  void _checkUserMatch() {
    if (matchImg == null || matchTxt == null) return;

    final correctText = matchImg!.split('/').last.replaceAll('.png', '').toUpperCase();

    if (correctText == matchTxt) {
      setState(() {
        userMatch[matchImg!] = matchTxt!;
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

    matchImg = null;
    matchTxt = null;
  }

  void _createPossibleAnswers() {
    final correctImage = multipleChoiceQuestions[tutorialIndex]['answer'] as String;

    final wrongImages = images
        .where((img) => img != correctImage)
        .toList()
      ..shuffle();

    possibleAnswers = [
      correctImage,
      wrongImages[0],
      wrongImages[1],
    ]..shuffle();

    answerIndex = null;
  }

  Future<void> _loadReadingTutorials() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('readingTutorials').get();

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    readingTutorials = data.values
        .map((value) => Map<String, dynamic>.from(value))
        .where((readingTutorial) => readingTutorial['lessonNum'] == widget.lesson['lessonNum'])
        .toList();

    readingTutorials.sort((a, b) => (a['readingTutorial'] as int).compareTo(b['readingTutorial'] as int));

    setState(() {});
  }

  Future<void> _loadQuestions() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('questions').get();

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    multipleChoiceQuestions = data.values
        .map((value) => Map<String, dynamic>.from(value))
        .where((question) => (question['type'] == "multipleChoice" && question['lessonNum'] == widget.lesson['lessonNum']))
        .toList();

    multipleChoiceQuestions.sort((a, b) => (a['questionNum'] as int).compareTo(b['questionNum'] as int));

    signToTextQuestions = data.values
        .map((value) => Map<String, dynamic>.from(value))
        .where((question) => (question['type'] == "text" && question['lessonNum'] == widget.lesson['lessonNum']))
        .toList();

    signToTextQuestions.sort((a, b) => (a['questionNum'] as int).compareTo(b['questionNum'] as int));

    setState(() {});
  }

  void _next() async {
    if (tutorial) {
      setState(() {
        tutorial = false;
        _createPossibleAnswers();
      });
      return;
    }

    if (quiz && signToText >= signToTextQuestions.length - 1 && matchQuestions.isNotEmpty) {
      if (userMatch.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You should match all images and text!'),
            duration: Duration(seconds: 1),
          ),
        );
        return;
      }

      if (matchIndex < matchQuestions.length - 1) {
        setState(() {
          matchIndex++;
          userMatch.clear();
        });
        return;
      } else {
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

        if (widget.lesson['lessonNum'] > dbCompletedLessons) {
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
    } else if (quiz && signToTextQuestions.isNotEmpty && signToText < signToTextQuestions.length) {
      final inputAnswer = answerTextController.text.trim().toUpperCase();
      final correctAnswer = signToTextQuestions[signToText]['answer'].toString();

      if (inputAnswer == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You should type an answer!'),
            duration: Duration(seconds: 1),
          ),
        );
        return;
      }

      if (inputAnswer != correctAnswer) {
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
        return;
      }
      else {
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

      if (signToText < signToTextQuestions.length - 1) {
        setState(() {
          signToText++;
          answerTextController.clear();
        });

        return;
      }
    } else {
      final correctAnswer = multipleChoiceQuestions[tutorialIndex]['answer'];

      if (answerIndex == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You should select an answer!'),
            duration: Duration(seconds: 1),
          ),
        );
        return;
      }

      answer = possibleAnswers[answerIndex!];

      if (answer != correctAnswer) {
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
        return;
      }
      else {
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
      } else if (tutorialIndex >= readingTutorials.length - 1 && quiz == false) {
        setState(() {
          quiz = true;
        });

        return;
      }
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
    }
  }

  @override
  void initState() {
    super.initState();

    answerTextController = TextEditingController();
    _loadReadingTutorials();
    _loadQuestions();
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
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(
            "Lesson ${widget.lesson['lessonNum']}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: readingTutorials.isEmpty ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: quiz ? signToText >= signToTextQuestions.length - 1 ? Column(
              children: [
                const SizedBox(height: 15.0),
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
                    'Match the images to their meaning:',
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                Column(
                  children: List.generate(matchQuestions[matchIndex]['shuffledPairs'].length, (index) {
                      final img = matchQuestions[matchIndex]['correctPairs'][index]['image'];
                      final txt = matchQuestions[matchIndex]['shuffledPairs'][index]['text'];

                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  matchImg = img;
                                  _checkUserMatch();
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: userMatch[img] != null ? Colors.green : Colors.grey,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Image.asset(
                                  img,
                                  width: 130,
                                  height: 130,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 30.0),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  matchTxt = txt;
                                  _checkUserMatch();
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: userMatch.containsValue(txt) ? Colors.green : Colors.grey,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                  color: Colors.purple.shade50,
                                ),
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  txt,
                                  style: const TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
            : Column(
              children: [
                const SizedBox(height: 15.0),
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
                    signToTextQuestions[signToText]['question'],
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                Image.asset(
                  signToTextQuestions[signToText]['questionContent'],
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.contain,
                ),
                if(!tutorial) ...[
                  const SizedBox(height: 30.0),
                  TextField(
                      controller: answerTextController,
                      //autofocus: true,
                      decoration: const InputDecoration(
                          labelText: 'Type...',
                          border: OutlineInputBorder()
                      )
                  ),
                ],
              ],
            )
            : Column(
              children: [
                const SizedBox(height: 15.0),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    border: Border.all(),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.lesson['name'],
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
                    tutorial ? readingTutorials[tutorialIndex]['tutorialText'] : multipleChoiceQuestions[tutorialIndex]['question'],
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if(tutorial) ...[
                  const SizedBox(height: 15.0),
                  Image.asset(
                    readingTutorials[tutorialIndex]['tutorialImage'],
                    width: double.infinity,
                    height: 400,
                    fit: BoxFit.contain,
                  ),
                ] else ...[
                  const SizedBox(height: 15.0),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      border: Border.all(),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      multipleChoiceQuestions[tutorialIndex]['questionContent'],
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15.0),
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
                                    width: 2.0,
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
              ],
            ),
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: !quiz ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.end,
          children: [
            if (!quiz) ...[
              ElevatedButton(
                onPressed: _previous,
                child: Text(
                  'Previous',
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black
                  )
                ),
              ),
            ],
            ElevatedButton(
              onPressed: _next,
              child: Text(
                'Next',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}