import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/badge_class.dart';
import '../classes/user_class.dart';
import '../services/general_service.dart';
import '../services/user_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen ({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
  final UserService userService = UserService();
  final GeneralService generalService = GeneralService();

  UserClass? user;
  List<BadgeClass> badges = [];
  bool darkMode = true;

  Future<void> _loadUserLocalStorage() async {
    user = await userService.loadUserLocalStorage();

    if (user != null) {
      setState(() {});
    }
  }

  Future<void> _loadBadges() async {
    badges = await generalService.loadBadges();
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
    _loadBadges();
    _loadUserLocalStorage();
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
            )
          ),
        ),
        title: const Text(
          "Achievements",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: badges.isEmpty ? const Center(child: CircularProgressIndicator()) : Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: darkMode ? Colors.black : Colors.white,
                  border: Border.all(width: 2.0, color: Colors.orange.shade300),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Scroll to see your badges",
                  style: TextStyle(fontSize: 16.0,),
                ),
              ),
              const SizedBox(height: 10.0),
              Expanded(
                child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: badges.length,
                  itemBuilder: (context, index) {
                    final badge = badges[index];
                    final bool earned = user?.badges.contains(badge.badgeNum) ?? false;

                    return Opacity(
                      opacity: earned ? 1.0 : 0.6,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.deepOrange,),
                          borderRadius: BorderRadius.circular(15.0),
                          gradient: LinearGradient(colors: darkMode
                              ? [Colors.grey.shade900, Colors.black]
                              : [Colors.orange.shade100, Colors.white],),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ColorFiltered(
                              colorFilter: earned
                                ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                                : (darkMode ? ColorFilter.mode(Colors.transparent, BlendMode.saturation) : ColorFilter.mode(Colors.grey.shade200, BlendMode.saturation)),
                              child: Image.asset(
                                badge.badgeImage,
                                height: 100,
                                width: 100,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    badge.badgeName,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: earned ? Colors.deepOrange.shade900 : Colors.grey.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    badge.badgeDesc + (earned ? " (Earned)" : " to unlock this badge."),
                                    softWrap: true,
                                    style: TextStyle(fontSize: 14.0,),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}