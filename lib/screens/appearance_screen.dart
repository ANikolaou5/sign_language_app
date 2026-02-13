import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key, required this.onThemeChange});

  final Function(bool) onThemeChange;

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
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
          "Appearance",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 25.0),
              Text(
                "THEME SETTINGS",
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: Icon(
                        darkMode ? Icons.dark_mode : Icons.light_mode,
                        color: Colors.deepOrange,
                        size: 40,
                      ),
                      title: const Text(
                        "Dark Mode",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Switch(
                        value: darkMode,
                        activeThumbColor: Colors.deepOrange,
                        onChanged: (bool value) async {
                          setState(() {
                            darkMode = value;
                          });

                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('darkMode', value);
                          widget.onThemeChange(value);
                        },
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    Text(
                      "Switching to Dark Mode saves battery life and makes it more comfortable to use the app in low-light environments.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}