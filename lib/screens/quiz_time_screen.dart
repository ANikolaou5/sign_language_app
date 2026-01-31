import 'package:flutter/material.dart';

import '../services/general_service.dart';
import '../services/user_service.dart';

class QuizTimeScreen extends StatefulWidget {
  const QuizTimeScreen({super.key, required this.username});

  final String username;

  @override
  State<QuizTimeScreen> createState() => _FingerspellSignToWordScreenState();
}

class _FingerspellSignToWordScreenState extends State<QuizTimeScreen> {
  final GeneralService generalService = GeneralService();
  final UserService userService = UserService();

  String difficulty = 'Easy';
  String category = 'Spell';
  bool timer = false;
  int numOfQuestions = 5;

  final List<String> difficultyOptions = ['Easy', 'Hard'];
  final List<String> categoriesOptions = ['Spell', 'Drag', 'Word'];
  final List<String> timerOptions = ['ON', 'OFF'];
  final List<String> numOfQuestionsOptions = ['5', '10', '20'];

  @override
  void initState() {
    super.initState();
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
        generalService.exitPrompt(context, 'quiz');
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
            "Quiz Time",
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
              child: Column(
                children: [
                  Text(
                    "Set up Quiz Preferences",
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange.shade800,
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  Text(
                    "Difficulty",
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: difficultyOptions.map((option) {
                        bool selected = option == difficulty;

                        return GestureDetector(
                          onTap: () {
                            setState(() => difficulty = option);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                              color: selected ? Colors.orange.shade700 : Colors.white,
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: selected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  Text(
                    "Category",
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: category,
                        items: categoriesOptions.map((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (option) {
                          setState(() => category = option!);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  Text(
                    "Timer",
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: timerOptions.map((option) {
                        String selection = timer ? 'ON' : 'OFF';
                        bool selected = option == selection;

                        return GestureDetector(
                          onTap: () {
                            setState(() => timer = option == 'ON');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                              color: selected ? Colors.orange.shade700 : Colors.white,
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: selected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  Text(
                    "Number of Questions",
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: numOfQuestionsOptions.map((option) {
                        bool selected = option == numOfQuestions.toString();

                        return GestureDetector(
                          onTap: () {
                            setState(() => numOfQuestions = int.parse(option));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                              color: selected ? Colors.orange.shade700 : Colors.white,
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: selected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ),
    );
  }
}