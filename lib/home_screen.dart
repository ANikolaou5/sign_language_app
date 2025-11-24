import 'package:flutter/material.dart';

import 'account_screen.dart';
import 'learn_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final List<Widget> _screens = <Widget>[
    const HomeScreen(title: 'Home Page'),
    const LearnScreen(title: 'Learn Page'),
    const AccountScreen(title: 'Account Page'),
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
        title: Text(widget.title),
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
        selectedItemColor: Colors.amber[800],
        onTap: _onTap,
      ),
    );
  }
}
