import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

import '../classes/question_class.dart';
import '../classes/user_class.dart';
import '../services/general_service.dart';
import '../services/user_service.dart';
import 'mini_game_screen.dart';
import '../classes/online_quiz.dart';

class GameLobbyScreen extends StatefulWidget {
  const GameLobbyScreen({super.key});

  @override
  State<GameLobbyScreen> createState() => _GameLobbyScreenState();
}

class _GameLobbyScreenState extends State<GameLobbyScreen> {
  final UserService userService = UserService();
  final GeneralService generalService = GeneralService();
  UserClass? dbUser;
  List<UserClass> dbUsers = [];

  bool _isSearching = false;
  User? _user;
  String? _currentGameId;
  StreamSubscription? _matchSubscription;
  String ranking = '';
  bool _isAuthLoading = true;

  late final DatabaseReference _gamesRef;

  @override
  void initState() {
    super.initState();
    // Initialize reference here
    _gamesRef = FirebaseDatabase.instance.ref("games/matches");

    // Check current user status safely
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _user = currentUser;
      _isAuthLoading = false;
    }

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!mounted) return;
      setState(() {
        _user = user;
        _isAuthLoading = false;
      });
    });

    _loadUserLocalStorage().then((_) async {
      List<UserClass> users = await userService.loadTopUsersBasedOnWins(3);

      if (mounted) {
        setState(() {
          dbUsers = users;
        });
      }
    });
  }

  // Function to load username from local storage, when already logged in.
  Future<void> _loadUserLocalStorage() async {
    dbUser = await userService.loadUserLocalStorage();

    if (dbUser != null) {
      setState(() {
        ranking = _ranking(dbUser!.wins);
      });
    }
  }

  //  Function to calculate ranking based on total wins.
  String _ranking(int wins) {
    if (wins >= 150) return "Gold III";
    if (wins >= 125) return "Gold II";
    if (wins >= 100) return "Gold I";
    if (wins >= 80) return "Silver III";
    if (wins >= 60) return "Silver II";
    if (wins >= 40) return "Silver I";
    if (wins >= 20) return "Bronze III";
    if (wins >= 10) return "Bronze II";
    return "Bronze I";
  }

  // Inside _findMatch in GameLobbyScreen.dart
  Future<void> _createMatchWithQuestions(List<Question> selectedQuestions) async {
    final gameId = _gamesRef.push().key!;

    // Convert your list of Question objects to a list of Maps
    List<Map<String, dynamic>> questionsAsMaps =
    selectedQuestions.map((q) => q.toMap()).toList();

    await _gamesRef.child(gameId).set({
      "status": "waiting",
      "current_index": 0,
      "quiz_data": questionsAsMaps, // The series of questions is now in the DB
      "player_1": {"uid": _user!.uid, "score": 0},
      "question_answered_by": "",
    });

    _waitForOpponent(gameId);
  }

  Future<void> _findMatch() async {
    if (_user == null) return;

    setState(() => _isSearching = true);
    final uid = _user!.uid;

    try {
      final snapshot = await _gamesRef
          .orderByChild("status")
          .equalTo("waiting")
          .limitToFirst(1)
          .get();

      // Case 1: FOUND A WAITING MATCH (Join as Player 2)
      if (snapshot.exists && snapshot.value is Map) {
        final firstMatch = snapshot.children.first;
        final gameId = firstMatch.key!;
        _currentGameId = gameId;

        // Update the match to playing status and add yourself as player_2
        await _gamesRef.child(gameId).update({
          "player_2": {
            "uid": uid,
            "score": 0,
            "is_ready": true,
          },
          "status": "playing",
        });

        _navigateToGame(gameId);
      }
      // Case 2: NO MATCH FOUND (Create new as Player 1)
      else {
        final gameId = _gamesRef.push().key!;
        _currentGameId = gameId;

        // 1. SELECT QUESTIONS: Replace this placeholder with your actual question logic
        // For example: List<Question> selected = QuestionData.allQuestions.take(5).toList();
        List<Question> selectedQuestions = [
          Question(
            questionNum: 1,
            levelNum: 1,
            questionType: QuestionType.multipleChoice,
            question: "Which letter does this symbol sign?",
            questionContent: "assets/images/A.png",
            answer: "A",
          ),
          Question(
            questionNum: 2,
            levelNum: 1,
            questionType: QuestionType.multipleChoice,
            question: "Which letter does this symbol sign?",
            questionContent: "assets/images/B.png",
            answer: "B",
          ),
        ];

        // 2. CONVERT TO MAPS: Prepare for Firebase upload
        List<Map<String, dynamic>> questionsAsMaps =
        selectedQuestions.map((q) => q.toMap()).toList();

        // 3. SET INITIAL STATE: Upload questions and set status to waiting
        await _gamesRef.child(gameId).set({
          "status": "waiting",
          "current_index": 0,
          "question_answered_by": "",
          "quiz_data": questionsAsMaps, // Both players will pull from here
          "player_1": {
            "uid": uid,
            "score": 0,
            "is_ready": true,
          },
        });

        _waitForOpponent(gameId);
      }
    } catch (e) {
      debugPrint("Matchmaking Error: $e");
      setState(() {
        _isSearching = false;
        _currentGameId = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connection error: $e")),
        );
      }
    }
  }


  void _waitForOpponent(String gameId) {
    _matchSubscription = _gamesRef
        .child(gameId)
        .child("status")
        .onValue
        .listen((event) {
      if (event.snapshot.value == "playing") {
        _matchSubscription?.cancel();
        _navigateToGame(gameId);
      }
    });
  }

  Future<void> _cancelMatchmaking() async {
    _matchSubscription?.cancel();

    if (_currentGameId != null) {
      final ref = _gamesRef.child(_currentGameId!);

      final snapshot = await ref.get();
      if (snapshot.exists &&
          snapshot.child("status").value == "waiting") {
        await ref.remove();
      }
    }

    setState(() {
      _currentGameId = null;
      _isSearching = false;
    });
  }


  void _navigateToGame(String gameId) {
    if (!mounted) return;

    setState(() => _isSearching = false);

    final quiz = OnlineQuiz(
      signToTextQuestions: [],
      matchQuestions: [],
    );

    final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');

    usersRef
        .orderByChild('accountDetails/uid')
        .equalTo(_user!.uid)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        final Map<dynamic, dynamic> result = snapshot.value as Map;
        String username = result.keys.first.toString();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MiniGameScreen(
              myUsername: username,
              gameId: gameId,
              myUid: _user!.uid,
              quiz: quiz,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a spinner while we check if the user is logged in
    if (_isAuthLoading || dbUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Normal Lobby UI
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.orange.shade50,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.orange.shade500, Colors.deepOrange.shade800]),
            ),
          ),
          title: const Text(
            "Play Online",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              _buildPlayerCard(),
              const SizedBox(height: 40),
              _buildMatchmakingSection(),
              const Spacer(),
              _buildLeaderboardPreview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.deepOrange.shade200),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.deepOrange,
            child: Icon(Icons.person, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Player Stats",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("Total Wins: ${dbUser!.wins}"),
              Text("Rank: $ranking"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMatchmakingSection() {
    return Column(
      children: [
        const Text(
          "Compete with others in Real-Time!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 80,
          child: ElevatedButton(
            onPressed: _isSearching ? _cancelMatchmaking : _findMatch,
            style: ElevatedButton.styleFrom(
              backgroundColor:
              _isSearching ? Colors.grey : Colors.deepOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: _isSearching
                ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 8),
                Text("Cancel Matchmaking"),
              ],
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flash_on, size: 30),
                SizedBox(width: 10),
                Text(
                  "FIND MATCH",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardPreview() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          gradient: LinearGradient(colors: [Colors.orange.shade100, Colors.white],),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Top 3 Players",
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.workspace_premium,
                  color: Colors.orange.shade900,
                  size: 35.0,
                ),
              ],
            ),
            const Divider(height: 35.0),
            Column(
              children: dbUsers.map((user) {
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "${dbUsers.indexOf(user) + 1}",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15.0),
                    Expanded(
                      child: Text(
                        user.username,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                    Text(
                      "${user.wins} wins ",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      )
    );
  }
}