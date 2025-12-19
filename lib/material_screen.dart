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
  List<String> possibleAnswers = [];
  String? answer;
  int? answerIndex;
  int index = 0;
  bool tutorial = true;

  void _createPossibleAnswers() {
    final correctImage = multipleChoiceQuestions[index]['answer'] as String;

    final wrongImages = images
        .where((img) => img != correctImage)
        .toList()
      ..shuffle();

    possibleAnswers = [
      correctImage,
      wrongImages[0],
      wrongImages[1],
    ]..shuffle();
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
    } else {
      final correctAnswer = multipleChoiceQuestions[index]['answer'];

      if (answerIndex == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You should select an answer!')),
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
          ),
        );
      }

      if (index < readingTutorials.length - 1) {
        setState(() {
          tutorial = true;
          index++;
        });
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
    }
  }

  void _previous() {
    if (!tutorial) {
      setState(() {
        tutorial = true;
      });
    } else if (index > 0) {
      setState(() {
        tutorial = false;
        index--;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _loadReadingTutorials();
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
            child: Column(
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
                    tutorial ? readingTutorials[index]['tutorialText'] : multipleChoiceQuestions[index]['question'],
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if(tutorial) ...[
                  const SizedBox(height: 15.0),
                  Image.asset(
                    readingTutorials[index]['tutorialImage'],
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
                      multipleChoiceQuestions[index]['questionContent'],
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
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
