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

  final List<Widget> _screens = <Widget>[
    const HomeScreen(),
    const LearnScreen(),
    const AccountScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          _titles.elementAt(_index),
          style: const TextStyle(fontWeight: FontWeight.bold),
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
        selectedItemColor: Colors.purple,
        onTap: _onTap,
      ),
    );
  }
}
