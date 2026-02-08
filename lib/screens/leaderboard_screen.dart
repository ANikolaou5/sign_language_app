import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/user_class.dart';
import '../components/leaderboard_list_widget.dart';
import '../services/user_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen ({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
  final UserService userService = UserService();

  List<UserClass> users = [];
  bool darkMode = true;

  Future<void> _loadUsers() async {
    users = await userService.loadUsers();

    setState(() {});
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
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
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
          "Leaderboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final ranking = index + 1;
              return LeaderboardList(user: user, ranking: ranking);
            },
          ),
        ),
      )
    );
  }
}