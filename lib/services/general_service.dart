import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/classes/user_class.dart';

import '../classes/badge_class.dart';
import '../classes/question_class.dart';

class GeneralService {
  void snackBar(BuildContext context, String text, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Create the options for the sign to text questions based on the lesson number.
  List<String> createOptions(int lessonNum, int lastSignLesson) {
    List<String> options = [];

    if (lessonNum == 1) {
      options = ['A', 'B', 'C', 'D', 'E'];
    } else if (lessonNum == 2) {
      options = ['F', 'G', 'H', 'I', 'J'];
    } else if (lessonNum == 3) {
      options = ['K', 'L', 'M', 'N', 'O'];
    } else if (lessonNum == 4) {
      options = ['P', 'Q', 'R', 'S', 'T'];
    } else if (lessonNum == 5) {
      options = ['U', 'V', 'W', 'X', 'Y', 'Z'];
    } else if (lessonNum == 6) {
      options = ['1', '2', '3', '4', '5'];
    } else if (lessonNum == 7) {
      options = ['6', '7', '8', '9', '10'];
    }

    return options;
  }

  Future<List<Question>> loadAllQuestions({int? symbolsLevelNum}) async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('questions').get();
    if (!snapshot.exists || snapshot.value == null) return [];

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    List<Question> allQuestions = data.values
        .map((value) =>
        Question.fromMap(Map<String, dynamic>.from(value as Map)))
        .where((q) => q.levelNum == symbolsLevelNum)
        .toList();

    return allQuestions;
  }

  Future<List<Question>> loadSignToTextQuestions({int? numOfQuestions}) async {
    List<Question> allQuestions = await loadAllQuestions();

    List<Question> signToTextQuestions = allQuestions
        .where((q) => q.questionType == QuestionType.text)
        .toList();

    if (numOfQuestions != null) {
      signToTextQuestions = signToTextQuestions.take(numOfQuestions).toList();
    }

    return signToTextQuestions;
  }

  Future<List<Question>> loadMCQ({int? numOfQuestions}) async {
    List<Question> allQuestions = await loadAllQuestions();

    List<Question> multipleChoiceQuestions = allQuestions
        .where((q) => q.questionType == QuestionType.multipleChoice)
        .toList();

    if (numOfQuestions != null) {
      multipleChoiceQuestions = multipleChoiceQuestions.take(numOfQuestions).toList();
    }

    return multipleChoiceQuestions;
  }

  Future<List<Question>> loadMCQSignToWords({int? numOfQuestions}) async {
    List<Question> allQuestions = await loadAllQuestions();

    List<Question> multipleChoiceQuestionsSignToWords = allQuestions
        .where((q) => q.questionType == QuestionType.multipleChoiceSignToWords)
        .toList();

    if (numOfQuestions != null) {
      multipleChoiceQuestionsSignToWords = multipleChoiceQuestionsSignToWords.take(numOfQuestions).toList();
    }

    return multipleChoiceQuestionsSignToWords;
  }

  Future<List<Question>> loadMCQWordsToSign({int? numOfQuestions}) async {
    final int symbolsLevelNum = 5;
    List<Question> allQuestions = await loadAllQuestions(symbolsLevelNum: symbolsLevelNum);

    List<Question> multipleChoiceWordsToSign= allQuestions
        .where((q) => q.questionType == QuestionType.multipleChoiceWordsToSign)
        .toList();

    if (numOfQuestions != null) {
      multipleChoiceWordsToSign = multipleChoiceWordsToSign.take(numOfQuestions).toList();
    }

    return multipleChoiceWordsToSign;
  }

  List<Map<String, dynamic>> createMatchQuestions({int? numOfQuestions}) {
    List<Map<String, dynamic>> matchQuestions = [];
    final List<String> wordList = ["CAT", "BOX", "ZIP", "RED", "SKY", "FUN", "LOW"];

    for (String word in wordList) {
      List<String> chars = word.toUpperCase().split('');
      final List<Map<String, String>> correctPairs = chars.map((char) {
        return {
          'image': 'assets/images/$char.png',
          'text': char,
        };
      }).toList();

      final List<Map<String, String>> shuffledPairs = List<Map<String, String>>.from(correctPairs)..shuffle();

      matchQuestions.add({
        'correctPairs': correctPairs,
        'shuffledPairs': shuffledPairs,
      });
    }

    if (numOfQuestions != null) {
      matchQuestions = matchQuestions.take(numOfQuestions).toList();
    }

    return matchQuestions;
  }

  Future<List<BadgeClass>> loadBadges() async {
    final DatabaseReference badgesRef = FirebaseDatabase.instance.ref().child('badges');
    final snapshot = await badgesRef.get();
    if (!snapshot.exists) return [];

    List<BadgeClass> badges;
    final data = Map<dynamic, dynamic>.from(snapshot.value as Map);

    badges = data.entries.map((entry) {
      return BadgeClass.fromFirebase(Map<String, dynamic>.from(entry.value as Map));
    }).toList();

    badges.sort((a, b) => a.badgeNum.compareTo(b.badgeNum));
    return badges;
  }

  Future<void> loginPrompt(UserClass? user, BuildContext context, Function(int) changeIndex, bool req) async {
    final prefs = await SharedPreferences.getInstance();

    if (user == null) {
      bool showPrompt = prefs.getBool('showPrompt') ?? false;

      if (!showPrompt || req) {
        showDialog(
          context: context,
          barrierDismissible: !req,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            child: Container(
              padding: const EdgeInsets.all(25.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                gradient: LinearGradient(colors: [Colors.orange.shade100, Colors.white],),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Sign in for the full experience!",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    req ? "Sign in required for using this feature!" : "If you sign in/sign up, you can earn points, appear on the leaderboard and unlock more features!",
                    style: TextStyle(fontSize: 18.0),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 10.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    onPressed: () async {
                      if (!req) {
                        await prefs.setBool('showPrompt', true);
                      }
                      Navigator.pop(context);
                      changeIndex(5);
                    },
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  if (!req) ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      ),
                      onPressed: () async {
                        await prefs.setBool('showPrompt', true);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Continue as Guest',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> startPrompt(BuildContext context, VoidCallback onTap, IconData icon, String question) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              gradient: LinearGradient(colors: [Colors.orange.shade100, Colors.white],),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Colors.deepOrange,
                  size: 50,
                ),
                const SizedBox(height: 10.0),
                Text(
                  question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "No",
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        onTap();
                      },
                      child: const Text(
                        "Yes",
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Future<void> exitPrompt(BuildContext context, String txt) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            child: Container(
              padding: const EdgeInsets.all(25.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                gradient: LinearGradient(colors: [Colors.orange.shade100, Colors.white],),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Are you sure you want to exit this $txt?',
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    "Your progress in this $txt will not be saved until you finish.",
                    style: TextStyle(fontSize: 18.0),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "No",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          if (txt == "quiz") {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          "Yes",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  Future<void> complete(String username, int score) async {
    final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
    final userRef = usersRef.child(username);
    final DataSnapshot snapshot = await userRef.get();
    UserClass user = UserClass.fromFirebase(username, Map<String, dynamic>.from(snapshot.value as Map));

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    int streak = user.streakNum;

    if (user.lastStreakDate != null) {
      DateTime lastStreakDate = user.lastStreakDate!;
      DateTime lastDate = DateTime(lastStreakDate.year, lastStreakDate.month, lastStreakDate.day);
      int difference = today.difference(lastDate).inDays;

      if (difference == 1) {
        streak += 1;
      } else if (difference > 1) {
        streak = 1;
      }
    } else {
      streak = 1;
    }

    await userRef.update({
      'learningDetails/streakNum': streak,
      'learningDetails/lastStreakDate': today.toIso8601String(),
      'learningDetails/score': user.score + score,
    });
  }

  DateTime calculateEndTime(int length, String? difficulty) {
    DateTime endTime = DateTime.now().add(const Duration(minutes: 2));

    if (length == 3) {
      if (difficulty == "Easy") {
        endTime = DateTime.now().add(const Duration(minutes: 1, seconds: 00));
      } else if (difficulty == "Hard") {
        endTime = DateTime.now().add(const Duration(minutes: 00, seconds: 40));
      }
    } else if (length == 5) {
      if (difficulty == "Easy") {
        endTime = DateTime.now().add(const Duration(minutes: 1, seconds: 40));
      } else if (difficulty == "Hard") {
        endTime = DateTime.now().add(const Duration(minutes: 1, seconds: 00));
      }
    } else if (length == 7) {
      if (difficulty == "Easy") {
        endTime = DateTime.now().add(const Duration(minutes: 2, seconds: 20));
      } else if (difficulty == "Hard") {
        endTime = DateTime.now().add(const Duration(minutes: 1, seconds: 30));
      }
    }

    return endTime;
  }
}