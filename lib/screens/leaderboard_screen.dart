import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../classes/user_class.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen ({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
  List<User> users = [];

  Future<void> _loadUsers() async {
    final snapshot = await usersRef.get();
    if (!snapshot.exists) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    users = data.entries.map((entry) {
      return User.fromFirebase(entry.key, Map<String, dynamic>.from(entry.value as Map));
    }).toList();

    users.sort((b, a) => a.score.compareTo(b.score));

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.orange.shade50,
        appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.orange.shade500, Colors.deepOrange.shade800]),
          ),
        ),
        title: const Text(
          "Leaderboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final ranking = index + 1;
            return _leaderboardList(user, ranking);
          },
        ),
      )
    );
  }

  Widget _leaderboardList(User user, int ranking) {
    Color circleColor;

    if (ranking == 1) {
      circleColor = Colors.amber.shade600;
    } else if (ranking == 2) {
      circleColor = Colors.grey.shade400;
    } else if (ranking == 3) {
      circleColor = Colors.brown.shade300;
    } else {
      circleColor = Colors.deepOrange.shade200;
    }

    return Card(
      elevation: ranking <= 3 ? 4.0 : 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8.0),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            ranking.toString(),
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.username,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text("Completed Lessons: ${user.completedLessons}"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user.score.toString(),
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange.shade800,
              ),
            ),
            const Text(
              "points",
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      ),
    );
  }
}