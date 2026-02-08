import 'package:flutter/material.dart';
import 'package:sign_language_app/screens/about_screen.dart';
import 'package:sign_language_app/screens/inference_screen.dart';
import 'package:sign_language_app/screens/play_screen.dart';
import 'package:sign_language_app/screens/train_screen.dart';

import 'account_screen.dart';
import 'home_screen.dart';
import 'learn_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.onThemeChange});

  final Function(bool) onThemeChange;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  final _titles = [
    'Home',
    'Learning',
    'Training',
    'Play',
    'Live test',
    'Account',
  ];

  Widget _getScreen(int index) {
    switch (index) {
      case 0: return HomeScreen(key: const PageStorageKey('home'), changeIndex: changeIndex);
      case 1: return LearnScreen(key: const PageStorageKey('learn'), changeIndex: changeIndex);
      case 2: return TrainScreen(key: const PageStorageKey('train'), changeIndex: changeIndex);
      case 3: return PlayScreen(key: const PageStorageKey('play'), changeIndex: changeIndex);
      case 4: return InferenceScreen(key: const PageStorageKey('camera'), changeIndex: changeIndex);
      case 5: return AccountScreen(key: const PageStorageKey('account'), changeIndex: changeIndex, onThemeChange: widget.onThemeChange);
      default: return HomeScreen(key: const PageStorageKey('home'), changeIndex: changeIndex);
    }
  }

  bool darkMode = true;

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
    final bool darkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: darkMode
                  ? [Colors.grey.shade900, Colors.black]
                  : [Colors.orange.shade500, Colors.deepOrange.shade800],
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
      /*body: IndexedStack(
        index: _index,
        children: _screens,
      ),*/
      body: SafeArea(child: Center(child: _getScreen(_index))),
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
            icon: Icon(Icons.quiz_outlined),
            activeIcon: Icon(Icons.quiz),
            label: "Training",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports_outlined),
            activeIcon: Icon(Icons.sports_esports),
            label: "Play",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_camera_front_outlined),
            activeIcon: Icon(Icons.video_camera_front),
            label: "Live test",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Account",
          ),
        ],
        currentIndex: _index,
        selectedItemColor: darkMode ? Colors.orange.shade300 : Colors.deepOrange.shade800,          unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onTap,
      ),
    );
  }
}