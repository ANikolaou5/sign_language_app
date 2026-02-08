import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool darkMode = true;

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

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkMode ? Colors.black : const Color(0xFFF6F6F6),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: darkMode
                  ? [Colors.grey.shade900, Colors.black]
                  : [Colors.orange.shade500, Colors.deepOrange.shade800],
            ),
          ),
        ),
        title: const Text(
          "Quiz Time",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroIntro(),

              const SizedBox(height: 20),

              _OptionSection(
                title: "Difficulty",
                child: _SegmentedSelector(
                  options: difficultyOptions,
                  selected: difficulty,
                  darkMode: darkMode,
                  onSelect: (v) => setState(() => difficulty = v),
                ),
              ),

              _OptionSection(
                title: "Timer",
                child: _SegmentedSelector(
                  options: timerOptions,
                  selected: timer ? 'ON' : 'OFF',
                  darkMode: darkMode,
                  onSelect: (v) => setState(() => timer = v == 'ON'),
                ),
              ),

              _OptionSection(
                title: "Questions",
                child: _SegmentedSelector(
                  options: numOfQuestionsOptions,
                  selected: numOfQuestions.toString(),
                  darkMode: darkMode,
                  onSelect: (v) =>
                      setState(() => numOfQuestions = int.parse(v)),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Type of questions",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              _CategoryChips(
                options: categoriesOptions,
                selected: category,
                darkMode: darkMode,
                onSelect: (v) => setState(() => category = v),
              ),

              const SizedBox(height: 32),

              _PlayButton(
                onPressed: () {
                  generalService.startPrompt(
                    context,
                        () async {
                      await _generateQuiz(
                        difficulty,
                        category,
                        timer,
                        numOfQuestions,
                      );

                      if (matchQuestions.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MatchingScreen(
                              matchQuestions: matchQuestions,
                              username: widget.username,
                              quiz: true,
                              timer: timer,
                              difficulty: difficulty,
                            ),
                          ),
                        );
                      } else if (multipleChoiceQuestions.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReadTheSignScreen(
                              title: "Read the Sign",
                              multipleChoiceQuestions:
                              multipleChoiceQuestions,
                              username: widget.username,
                              quiz: true,
                              timer: timer,
                              difficulty: difficulty,
                              symbols: false,
                            ),
                          ),
                        );
                      } else if (signToTextQuestions.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FingerspellSignToWordScreen(
                                  signToTextQuestions: signToTextQuestions,
                                  username: widget.username,
                                  quiz: true,
                                  timer: timer,
                                  difficulty: difficulty,
                                ),
                          ),
                        );
                      } else if (multipleChoiceQuestionsWordsToSign
                          .isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WordsToSignScreen(
                              multipleChoiceQuestions:
                              multipleChoiceQuestionsWordsToSign,
                              username: widget.username,
                              quiz: true,
                              timer: timer,
                              difficulty: difficulty,
                            ),
                          ),
                        );
                      } else if (multipleChoiceQuestionsSignToWords
                          .isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReadTheSignScreen(
                              title: "Sign to Words",
                              multipleChoiceQuestions:
                              multipleChoiceQuestionsSignToWords,
                              username: widget.username,
                              quiz: true,
                              timer: timer,
                              difficulty: difficulty,
                              symbols: true,
                            ),
                          ),
                        );
                      }
                    },
                    Icons.sports_esports,
                    'Start quiz?',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _HeroIntro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Build your quiz",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Choose how you want to be challenged",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}

class _OptionSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _OptionSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          child,
        ],
      ),
    );
  }
}

class _SegmentedSelector extends StatelessWidget {
  final List<String> options;
  final String selected;
  final bool darkMode;
  final Function(String) onSelect;

  const _SegmentedSelector({
    required this.options,
    required this.selected,
    required this.darkMode,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: darkMode ? Colors.grey.shade900 : Colors.white,
      ),
      child: Row(
        children: options.map((option) {
          final isSelected = option == selected;

          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color:
                  isSelected ? Colors.deepOrange : Colors.transparent,
                ),
                child: Text(
                  option,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : darkMode
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> options;
  final String selected;
  final bool darkMode;
  final Function(String) onSelect;

  const _CategoryChips({
    required this.options,
    required this.selected,
    required this.darkMode,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = option == selected;

        return ChoiceChip(
          label: Text(
            option,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.white
                  : darkMode
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          selected: isSelected,
          selectedColor: Colors.deepOrange,
          backgroundColor:
          darkMode ? Colors.grey.shade900 : Colors.white,
          checkmarkColor: Colors.white,
          onSelected: (_) => onSelect(option),
        );
      }).toList(),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PlayButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: const Text(
          "PLAY QUIZ",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
