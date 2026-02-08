import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool darkMode = true;

  // Function to load username from local storage, when already logged in.
  Future<void> _loadUserLocalStorage() async {
    user = await userService.loadUserLocalStorage();

    if (user != null) {
      setState(() {});
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
    _loadUserLocalStorage().then((_) async {
      await generalService.loginPrompt(user, context, widget.changeIndex, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [

              Text(
                "Click on one of the below options to play alone or online.",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10.0),

              Center(
                child: Card(
                  elevation: 6.0,
                  shadowColor: Colors.orange.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QuizTimeScreen(username: user!.username)),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 35.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.deepOrange.shade700, Colors.orange.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(width: 1.5, color: Colors.orange.shade200),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.quiz,
                              size: 32,
                              color: Colors.deepOrange.shade700,
                            ),
                          ),
                          SizedBox(width: 20.0),
                          Expanded(
                            child: Text(
                              "Play a quiz",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w800,
                                color: Colors.white
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10.0),

              Center(
                child: Card(
                  elevation: 6.0,
                  shadowColor: Colors.orange.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      generalService.startPrompt(
                        context,
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const GameLobbyScreen()),
                          );
                        },
                        Icons.sports_esports,
                        'Start playing online?',
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 35.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.deepOrange.shade700, Colors.orange.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(width: 1.5, color: Colors.orange.shade200),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.public, // Icon for Play Online
                              size: 32,
                              color: Colors.deepOrange.shade700,
                            ),
                          ),
                          SizedBox(width: 20.0),
                          Expanded(
                            child: Text(
                              "Play online (1 vs 1)",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w800,
                                color: Colors.white
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}