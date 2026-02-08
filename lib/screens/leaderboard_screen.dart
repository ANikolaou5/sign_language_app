import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/user_class.dart';
import '../components/leaderboard_list_widget.dart';
import '../services/user_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final DatabaseReference usersRef =
  FirebaseDatabase.instance.ref().child('users');
  final UserService userService = UserService();

  final GlobalKey<AnimatedListState> _listKey =
  GlobalKey<AnimatedListState>();

  List<UserClass> users = [];
  bool darkMode = true;

  Future<void> _loadUsers() async {
    final loadedUsers = await userService.loadUsers();

    users.clear();
    setState(() {});

    for (int i = 0; i < loadedUsers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      users.add(loadedUsers[i]);
      _listKey.currentState?.insertItem(i);
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
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: darkMode
                  ? [Colors.grey.shade900, Colors.black]
                  : [
                Colors.orange.shade500,
                Colors.deepOrange.shade800
              ],
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
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: darkMode
                  ? [Colors.grey.shade900, Colors.black]
                  : [
                Colors.orange.shade500,
                Colors.deepOrange.shade800
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: AnimatedList(
              key: _listKey,
              initialItemCount: users.length,
              itemBuilder: (context, index, animation) {
                final user = users[index];
                final ranking = index + 1;

                return _AnimatedLeaderboardItem(
                  animation: animation,
                  child: LeaderboardList(
                    user: user,
                    ranking: ranking,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedLeaderboardItem extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _AnimatedLeaderboardItem({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(0, -0.25),
            end: Offset.zero,
          ).chain(
            CurveTween(curve: Curves.easeOutCubic),
          ),
        ),
        child: child,
      ),
    );
  }
}
