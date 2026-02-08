import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool darkMode = false;

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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASL Learning App',
      theme: ThemeData(brightness: Brightness.light, fontFamily: 'SNPro',),
      darkTheme: ThemeData(brightness: Brightness.dark, fontFamily: 'SNPro'),
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      home: MainScreen(
        onThemeChange: (bool value) {
          setState(() {
           darkMode = value;
          });
        }
      ),
    );
  }
}