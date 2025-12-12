import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key, required this.lesson});

  final Map<String, dynamic> lesson;

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  List<Map<String, dynamic>> readingTutorials = [];
  int index = 0;

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

  void _next() {
    if (index < readingTutorials.length - 1) {
      setState(() {
        index++;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _previous() {
    if (index > 0) {
      setState(() {
        index--;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _loadReadingTutorials();
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
          child: readingTutorials.isEmpty ? const Center(child: CircularProgressIndicator()) : Column(
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
                  readingTutorials[index]['tutorialText'],
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30.0),
              Image.asset(
                readingTutorials[index]['tutorialImage'],
                width: double.infinity,
                height: 400,
                fit: BoxFit.contain,
              ),
            ],
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
