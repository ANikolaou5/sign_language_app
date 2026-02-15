import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'screens/main_screen.dart';

Widget _buildRunnableApp({
  required bool isWeb,
  required double webAppWidth,
  required double webAppHeight,
  required Widget app,
}) {
  if (!isWeb) {
    return app;
  }

  return Center(
    child: ClipRect(
      child: SizedBox(
        width: webAppWidth,
        height: webAppHeight,
        child: app,
      ),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }
  else {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  }

  final runnableApp = _buildRunnableApp(
    isWeb: kIsWeb,
    webAppWidth: 480,
    webAppHeight: 960,
    app: const MyApp(),
  );

  runApp(runnableApp);
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
      debugShowCheckedModeBanner: false,
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