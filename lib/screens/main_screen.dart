import 'package:flutter/material.dart';

import 'account_screen.dart';
import 'home_screen.dart';
import 'learn_screen.dart';

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
    'Account',
  ];

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      HomeScreen(changeIndex: changeIndex),
      LearnScreen(changeIndex: changeIndex),
      AccountScreen(changeIndex: changeIndex),
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
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.orange.shade500, Colors.deepOrange.shade800]),
          ),
        ),
        title: Text(
          _titles.elementAt(_index),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
          child: _screens.elementAt(_index)
      ),
      // api.flutter.dev. (n.d.). BottomNavigationBar class - material library - Dart API. [online]
      // Available at: https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html
      // [Accessed 24 Nov. 2025].
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Learn",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Account",
          ),
        ],
        currentIndex: _index,
        selectedItemColor: Colors.deepOrange.shade800,
        onTap: _onTap,
      ),
    );
  }
}
