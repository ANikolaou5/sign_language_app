import 'package:flutter/material.dart';
import 'package:sign_language_app/screens/game_lobby_screen.dart';
import 'package:sign_language_app/screens/quiz_time_screen.dart';

import '../classes/user_class.dart';
import '../services/general_service.dart';
import '../services/user_service.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key, required this.changeIndex});

  final Function(int) changeIndex;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  final UserService userService = UserService();
  final GeneralService generalService = GeneralService();
  UserClass? user;

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
      /*signToTextQuestions = await generalService.loadSignToTextQuestions();
      multipleChoiceQuestions = await generalService.loadMCQ();
      matchQuestions = generalService.createMatchQuestions();*/
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
            Center(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QuizTimeScreen(username: user!.username),
                    ),
                  );
                },
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                  child: Container(
                    padding: const EdgeInsets.all(49.0),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.shade200,
                      border: Border.all(width: 2.0, color: Colors.orange.shade300),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "QUIZ TIME",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange.shade800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Center(
              child: InkWell(
                onTap: () {
                  generalService.startPrompt(
                    context,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GameLobbyScreen(),
                        ),
                      );
                    },
                    Icons.sports_esports,
                    'Start playing online?',
                  );
                },
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                  child: Container(
                    padding: const EdgeInsets.all(49.0),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.shade200,
                      border: Border.all(width: 2.0, color: Colors.orange.shade300),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "PLAY ONLINE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange.shade800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}