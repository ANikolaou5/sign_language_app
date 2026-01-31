import 'package:flutter/material.dart';
import 'package:sign_language_app/components/train_categories_widget.dart';
import 'package:sign_language_app/screens/matching_screen.dart';
import 'package:sign_language_app/screens/fingerspell_sign_to_word_screen.dart';
import 'package:sign_language_app/screens/read_the_sign_screen.dart';

import '../classes/question_class.dart';
import '../classes/user_class.dart';
import '../services/general_service.dart';
import '../services/user_service.dart';

class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key, required this.changeIndex});

  final Function(int) changeIndex;

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  final UserService userService = UserService();
  final GeneralService generalService = GeneralService();
  UserClass? user;

  List<Question> signToTextQuestions = [];
  List<Question> multipleChoiceQuestions = [];
  List<Map<String, dynamic>> matchQuestions = [];

  // Function to load username from local storage, when already logged in.
  Future<void> _loadUserLocalStorage() async {
    user = await userService.loadUserLocalStorage();

    if (user != null) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    _loadUserLocalStorage().then((_) async {
      await generalService.loginPrompt(user, context, widget.changeIndex, true);
      signToTextQuestions = await generalService.loadSignToTextQuestions();
      multipleChoiceQuestions = await generalService.loadMCQ();
      matchQuestions = generalService.createMatchQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(height: 10.0),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                border: Border.all(width: 2.0, color: Colors.orange.shade300),
                borderRadius: BorderRadius.circular(15.0),
              ),
              alignment: Alignment.center,
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            TrainCategories(
              name: "DRAG & DROP TO FINGERSPELL",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MatchingScreen(matchQuestions: matchQuestions, username: user!.username,),
                  ),
                );
              },
              generalService: generalService,
            ),
            const SizedBox(height: 10.0),
            TrainCategories(
              name: "READ THE SIGN",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReadTheSignScreen(multipleChoiceQuestions: multipleChoiceQuestions, username: user!.username),
                  ),
                );
              },
              generalService: generalService,
            ),
            const SizedBox(height: 10.0),
            TrainCategories(
              name: "FINGERSPELL IMAGE TO WORD",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FingerspellSignToWordScreen(signToTextQuestions: signToTextQuestions, username: user!.username),
                  ),
                );
              },
              generalService: generalService,
            ),
          ],
        ),
      ),
    );
  }
}