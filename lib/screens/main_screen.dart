import 'package:flutter/material.dart';
import 'package:sign_language_app/screens/inference_screen.dart';

import 'account_screen.dart';
import 'home_screen.dart';
import 'learn_screen.dart';
import 'game_lobby_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  final _titles = [
    'Home',
    'Learn',
    'Play',
    'Account',
    'Inference',
  ];

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      HomeScreen(key: const PageStorageKey('home'), changeIndex: changeIndex),
      LearnScreen(key: const PageStorageKey('learn'), changeIndex: changeIndex),
      // This is the entry point for your mini-game system
      GameLobbyScreen(key: const PageStorageKey('play'), changeIndex: changeIndex),
      AccountScreen(key: const PageStorageKey('account'), changeIndex: changeIndex),
      InferenceScreen(key: const PageStorageKey('inference'), changeIndex: changeIndex),
    ];
  }

  void _onTap(int index) {
    setState(() {
      _index = index;
    });
  }

  void changeIndex(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade500, Colors.deepOrange.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          _titles[_index],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      /*body: IndexedStack(
        index: _index,
        children: _screens,
      ),*/
      body: Center(child: _screens.elementAt(_index)),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: "Learn",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports_outlined),
            activeIcon: Icon(Icons.sports_esports),
            label: "Play",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Account",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_camera_front_outlined),
            activeIcon: Icon(Icons.video_camera_front),
            label: "Inference",
          ),
        ],
        currentIndex: _index,
        selectedItemColor: Colors.deepOrange.shade800,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onTap,
      ),
    );
  }
}