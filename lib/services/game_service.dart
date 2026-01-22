import 'package:firebase_database/firebase_database.dart';

class GameService {
  final String gameId;
  final String myUid;
  final DatabaseReference _dbRef;

  GameService(this.gameId, this.myUid)
      : _dbRef = FirebaseDatabase.instance.ref("games/matches/$gameId");

  Future<void> submitAnswer(dynamic userAnswer, dynamic correctAnswer) async {
    final bool isCorrect = userAnswer.toString().trim().toLowerCase() ==
        correctAnswer.toString().trim().toLowerCase();

    // 1. Handle Incorrect Answer immediately
    if (!isCorrect) {
      // We need to find if we are player_1 or player_2 to deduct points
      final snapshot = await _dbRef.get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        String playerKey = data['player_1']['uid'] == myUid ? 'player_1' : 'player_2';

        await _dbRef.child("$playerKey/score").set(ServerValue.increment(-5));
      }
      return;
    }

    // 2. Handle Correct Answer via Transaction
    await _dbRef.runTransaction((Object? post) {
      if (post == null) return Transaction.abort();

      Map<String, dynamic> game = Map<String, dynamic>.from(post as Map);

      // Determine if I am player_1 or player_2 inside the transaction
      String? myPlayerKey;
      if (game['player_1'] != null && game['player_1']['uid'] == myUid) {
        myPlayerKey = 'player_1';
      } else if (game['player_2'] != null && game['player_2']['uid'] == myUid) {
        myPlayerKey = 'player_2';
      }

      if (myPlayerKey == null) return Transaction.abort();

      // Ensure the player map is properly cast
      game[myPlayerKey] = Map<String, dynamic>.from(game[myPlayerKey] as Map);

      // Only reward if no one else has claimed this question yet
      if (game['question_answered_by'] == "" || game['question_answered_by'] == null) {
        game['question_answered_by'] = myUid;

        int currentScore = game[myPlayerKey]['score'] ?? 0;
        game[myPlayerKey]['score'] = currentScore + 10;
      }

      return Transaction.success(game);
    });
  }

  Stream<DatabaseEvent> get gameStream => _dbRef.onValue;

  Future<void> goToNextQuestion(int expectedIndex) async {
    await _dbRef.runTransaction((Object? post) {
      if (post == null) return Transaction.abort();

      Map<String, dynamic> game = Map<String, dynamic>.from(post as Map);
      int currentIndex = game['current_index'] ?? 0;

      if (currentIndex == expectedIndex) {
        game['current_index'] = currentIndex + 1;
        game['question_answered_by'] = "";
        return Transaction.success(game);
      } else {
        return Transaction.abort();
      }
    });
  }
}