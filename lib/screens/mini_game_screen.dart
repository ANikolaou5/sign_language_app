import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/game_service.dart';
import '../classes/question_class.dart';
import '../classes/online_quiz.dart';

class MiniGameScreen extends StatefulWidget {

  final String gameId;
  final String myUid;
  final String myUsername;
  final OnlineQuiz quiz;

  const MiniGameScreen({
    super.key,
    required this.myUsername,
    required this.gameId,
    required this.myUid,
    required this.quiz,
  });

  @override
  State<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends State<MiniGameScreen> {
  late GameService _gameService;
  final TextEditingController _answerController = TextEditingController();
  bool _isProcessing = false;
  bool _hasMovedToNext = false;
  bool _rewardProcessed = false; // Ensures rewards only trigger once

  @override
  void initState() {
    super.initState();
    _gameService = GameService(widget.gameId, widget.myUid);
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  /// Handles final score calculation and database updates for Wins/Losses/Draws
  void _processGameRewards(int myScore, int opponentScore) async {
    if (_rewardProcessed) return;
    _rewardProcessed = true;

    int bonusPoints = 0;
    String statType = ""; // "wins", "draws", or "losses"

    if (myScore > opponentScore) {
      bonusPoints = 50;
      statType = "wins";
    } else if (myScore == opponentScore) {
      bonusPoints = 20;
      statType = "draws";
    } else {
      bonusPoints = 0;
      statType = "losses";
    }

    // Total = myScore (which is already 10 * correct answers) + win/draw bonus
    int totalReward = myScore + bonusPoints;

    final userRef = FirebaseDatabase.instance.ref("users/${widget.myUsername}");

    try {
      await userRef.runTransaction((Object? post) {
        Map<String, dynamic> user = post != null
            ? Map<String, dynamic>.from(post as Map)
            : {};

        // Initialize structures if they don't exist
        user['learningDetails'] ??= {};
        user['gameStats'] ??= {};

        // Update total cumulative score
        int currentTotalScore = user['learningDetails']['score'] ?? 0;
        user['learningDetails']['score'] = currentTotalScore + totalReward;

        // Update Win/Loss/Draw counter
        int currentCount = user['gameStats'][statType] ?? 0;
        user['gameStats'][statType] = currentCount + 1;

        return Transaction.success(user);
      });
      print("Rewards processed: +$totalReward points and +1 to $statType");
    } catch (e) {
      print("Error processing rewards: $e");
    }
  }

  void _handleAnswer(String userAnswer, String correctAnswer) async {
    if (_isProcessing || userAnswer.isEmpty) return;

    setState(() => _isProcessing = true);

    bool isCorrect = userAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();

    // GameService handles the +10 or -5 points internally in the games/ node
    await _gameService.submitAnswer(userAnswer.trim(), correctAnswer);

    if (isCorrect) {
      _answerController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Incorrect! -5 points"),
          duration: Duration(milliseconds: 800),
          backgroundColor: Colors.redAccent,
        ),
      );
    }

    setState(() => _isProcessing = false);
  }

  void _triggerAutoProgression(int currentIndex) {
    if (_hasMovedToNext) return;
    _hasMovedToNext = true;

    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        // Use the new safe method instead of the old goToNextQuestion
        await _gameService.goToNextQuestion(currentIndex);

        if (mounted) {
          setState(() {
            _hasMovedToNext = false;
            _answerController.clear();
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Multiplayer Match"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _gameService.gameStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);

          final List<dynamic> questionsData = data['quiz_data'] ?? [];
          final int currentIndex = data['current_index'] ?? 0;
          final String answeredBy = data['question_answered_by'] ?? "";

          if (answeredBy != "") {
            _triggerAutoProgression(currentIndex);
          }

          // 1. Identify which player is "Me" and which is "Opponent"
          Map<String, dynamic> myData = {};
          Map<String, dynamic> opponentData = {"score": 0};

          if (data['player_1'] != null && data['player_1']['uid'] == widget.myUid) {
            // I am player 1
            myData = Map<String, dynamic>.from(data['player_1'] as Map);
            if (data['player_2'] != null) {
              opponentData = Map<String, dynamic>.from(data['player_2'] as Map);
            }
          } else if (data['player_2'] != null && data['player_2']['uid'] == widget.myUid) {
            // I am player 2
            myData = Map<String, dynamic>.from(data['player_2'] as Map);
            if (data['player_1'] != null) {
              opponentData = Map<String, dynamic>.from(data['player_1'] as Map);
            }
          }

          // --- Game End Check ---
          if (currentIndex >= questionsData.length && questionsData.isNotEmpty) {
            // Check if someone JUST answered the last question
            // If so, wait a moment for the score update to arrive before showing results
            if (answeredBy != "") {
              return const Center(child: Text("Calculating final scores..."));
            }

            final myFinalScore = myData['score'] ?? 0;
            final opponentFinalScore = opponentData['score'] ?? 0;

            _processGameRewards(myFinalScore, opponentFinalScore);
            return _buildResultsScreen(myFinalScore, opponentFinalScore);
          }

          if (questionsData.isEmpty) return const Center(child: Text("Loading questions..."));

          final currentMap = Map<String, dynamic>.from(questionsData[currentIndex]);
          final currentQuestion = Question.fromMap(currentMap);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildScoreboard(myData['score'] ?? 0, opponentData['score'] ?? 0),
                const SizedBox(height: 20),
                Text(
                  "Question ${currentIndex + 1} of ${questionsData.length}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Text(
                  currentQuestion.question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      currentQuestion.questionContent,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (answeredBy == "") ...[
                  TextField(
                    controller: _answerController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Type the sign here...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: Colors.deepOrange),
                        onPressed: () => _handleAnswer(_answerController.text, currentQuestion.answer),
                      ),
                    ),
                    onSubmitted: (val) => _handleAnswer(val, currentQuestion.answer),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: answeredBy == widget.myUid ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          answeredBy == widget.myUid ? "YOU WERE FIRST! 🎉" : "OPPONENT GOT IT! 💨",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: answeredBy == widget.myUid ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text("Answer: ${currentQuestion.answer}", style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreboard(int myScore, int opponentScore) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _scoreItem("You", myScore, Colors.blue),
        const Text("VS", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
        _scoreItem("Opponent", opponentScore, Colors.red),
      ],
    );
  }

  Widget _scoreItem(String label, int score, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text("$score", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildResultsScreen(int myScore, int opponentScore) {
    bool iWon = myScore > opponentScore;
    bool isDraw = myScore == opponentScore;

    String resultText = iWon ? "VICTORY!" : (isDraw ? "DRAW!" : "DEFEAT");
    IconData resultIcon = iWon ? Icons.emoji_events : (isDraw ? Icons.handshake : Icons.sentiment_very_dissatisfied);
    Color resultColor = iWon ? Colors.amber : (isDraw ? Colors.blue : Colors.grey);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(resultIcon, size: 100, color: resultColor),
          const SizedBox(height: 20),
          Text(resultText, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          Text("Final Score: $myScore - $opponentScore", style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          const Text("Rewards have been added to your profile!", style: TextStyle(color: Colors.green)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Return to Lobby"),
          )
        ],
      ),
    );
  }
}