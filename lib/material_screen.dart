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
  late TextEditingController answerTextController;
  List<Map<String, dynamic>> readingTutorials = [];
  List<Map<String, dynamic>> questions = [];
  int index = 0;
  bool tutorial = true;

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

    questions = data.values
        .map((value) => Map<String, dynamic>.from(value))
        .where((question) => question['lessonNum'] == widget.lesson['lessonNum'])
        .toList();

    questions.sort((a, b) => (a['questionNum'] as int).compareTo(b['questionNum'] as int));

    setState(() {});
  }

  void _next() async {
    if (tutorial) {
      setState(() {
        tutorial = false;
        answerTextController.clear();
      });
    } else {
      final inputAnswer = answerTextController.text.trim().toUpperCase();
      final correctAnswer = questions[index]['answer'].toString();

      if (inputAnswer == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You should type an answer!')),
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

        await userRef.update({
          'learningDetails': {
            'streakNum': dbStreakNum,
            'streakNumGoal': dbStreakNumGoal,
            'score': dbScore + 10,
            'completedLessons': dbCompletedLessons + 1,
          }
        });

        Navigator.pop(context);
      }
    }
  }

  void _previous() {
    if (!tutorial) {
      setState(() {
        tutorial = true;
        answerTextController.clear();
      });
    } else if (index > 0) {
      setState(() {
        tutorial = false;
        index--;
        answerTextController.clear();
      });
    }
  }

  @override
  void initState() {
    super.initState();

    answerTextController = TextEditingController();
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
                const SizedBox(height: 30.0),
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
                const SizedBox(height: 30.0),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    border: Border.all(),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tutorial ? readingTutorials[index]['tutorialText'] : questions[index]['question'],
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                Image.asset(
                  tutorial ? readingTutorials[index]['tutorialImage'] : questions[index]['questionContent'],
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.contain,
                ),
                if(!tutorial) ...[
                  const SizedBox(height: 30.0),
                  TextField(
                    controller: answerTextController,
                      autofocus: true,
                    decoration: const InputDecoration(
                        labelText: 'Type...',
                        border: OutlineInputBorder()
                    )
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
