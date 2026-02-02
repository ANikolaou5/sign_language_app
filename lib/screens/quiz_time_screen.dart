import 'package:flutter/material.dart';
import 'package:sign_language_app/screens/fingerspell_sign_to_word_screen.dart';
import 'package:sign_language_app/screens/matching_screen.dart';
import 'package:sign_language_app/screens/read_the_sign_screen.dart';
import 'package:sign_language_app/screens/words_to_sign_screen.dart';

import '../classes/question_class.dart';
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
  String category = 'Drag & Drop';
  bool timer = false;
  int numOfQuestions = 3;

  List<Map<String, dynamic>> matchQuestions = [];
  List<Question> multipleChoiceQuestions = [];
  List<Question> signToTextQuestions = [];
  List<Question> multipleChoiceQuestionsWordsToSign = [];
  List<Question> multipleChoiceQuestionsSignToWords = [];

  final List<String> difficultyOptions = ['Easy', 'Hard'];
  final List<String> categoriesOptions = ['Drag & Drop', 'Read the Sign', 'Image to Word', 'Words to Sign', 'Sign to Words'];
  final List<String> timerOptions = ['ON', 'OFF'];
  final List<String> numOfQuestionsOptions = ['3', '5', '7'];

  Future<void> _generateQuiz(String difficulty, String category, bool timer, int numOfQuestions) async {
    matchQuestions.clear();
    multipleChoiceQuestions.clear();
    signToTextQuestions.clear();
    multipleChoiceQuestionsWordsToSign.clear();
    multipleChoiceQuestionsSignToWords.clear();

    if (category == "Drag & Drop") {
      matchQuestions = generalService.createMatchQuestions(numOfQuestions: numOfQuestions);
    } else if (category == "Read the Sign") {
      multipleChoiceQuestions = await generalService.loadMCQ(numOfQuestions: numOfQuestions);
    } else if (category == "Image to Word") {
      signToTextQuestions = await generalService.loadSignToTextQuestions(numOfQuestions: numOfQuestions);
    } else if (category == 'Words to Sign') {
      multipleChoiceQuestionsWordsToSign = await generalService.loadMCQWordsToSign(numOfQuestions: numOfQuestions);
    } else if (category == 'Sign to Words') {
      multipleChoiceQuestionsSignToWords = await generalService.loadMCQSignToWords(numOfQuestions: numOfQuestions);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // GaneshTamang (2024). Flutter PopScope for android back button to leave app showing black screen instead of going to home screen of android. [online] GitHub.
    // Available at: https://github.com/GaneshTamang/flast_chat_firebase_example/issues/1
    // [Accessed 3 Dec. 2025].
  return Scaffold(
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
                            color: selected ? Colors.deepOrange : Colors.white,
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
                  child: DropdownButton(
                    value: category,
                    items: categoriesOptions.map((String option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (option) {
                      setState(() => category = option!);
                    },
                    iconSize: 40.0,
                    iconEnabledColor: Colors.deepOrange,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
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
                            color: selected ? Colors.deepOrange : Colors.white,
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
                            color: selected ? Colors.deepOrange: Colors.white,
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
                ElevatedButton(
                  onPressed: () {
                    generalService.startPrompt(
                      context,
                      () async {
                        await _generateQuiz(difficulty, category, timer, numOfQuestions);
                        if (matchQuestions.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MatchingScreen(matchQuestions: matchQuestions, username: widget.username, quiz: true, timer: timer, difficulty: difficulty,),
                            ),
                          );
                        } else if (multipleChoiceQuestions.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ReadTheSignScreen(title: "Read the Sign", multipleChoiceQuestions: multipleChoiceQuestions, username: widget.username, quiz: true, timer: timer, difficulty: difficulty, symbols: false,),
                            ),
                          );
                        } else if (signToTextQuestions.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FingerspellSignToWordScreen(signToTextQuestions: signToTextQuestions, username: widget.username, quiz: true, timer: timer, difficulty: difficulty,),
                            ),
                          );
                        } else if (multipleChoiceQuestionsWordsToSign.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => WordsToSignScreen(multipleChoiceQuestions: multipleChoiceQuestionsWordsToSign, username: widget.username, quiz: true, timer: timer, difficulty: difficulty,),
                            ),
                          );
                        } else if (multipleChoiceQuestionsSignToWords.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ReadTheSignScreen(title: "Sign to Words", multipleChoiceQuestions: multipleChoiceQuestionsSignToWords, username: widget.username, quiz: true, timer: timer, difficulty: difficulty, symbols: true,),
                            ),
                          );
                        }
                      },
                      Icons.sports_esports,
                      'Start quiz?',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    padding: const EdgeInsets.all(15.0),
                  ),
                  child: const Text(
                    'Generate Quiz',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          ),
        ),
      ),
    );
  }
}