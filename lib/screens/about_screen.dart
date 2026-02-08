import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen ({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  bool darkMode = true;

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
          "About SiLAc",
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
              const SizedBox(height: 30.0),
              Image.asset(
                "assets/logos/logo1.png",
                height: 180.0,
              ),
              const Text(
                "SiLAc",
                style: TextStyle(
                  fontSize: 42.0,
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Version 1.0.0",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30.0),
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(
                    color: Colors.deepOrange,
                    width: 2.0,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      "SiLAc is a mobile application for learning ASL using gamified, interactive activities that help users learn sign language through various features.",
                      style: TextStyle(fontSize: 16.0,),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 10.0),
                    Divider(
                      color: Colors.deepOrange,
                      thickness: 2.0,
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      "By merging learning design principles and gamification, SiLAc intends to shape sign language learning into a productive and enjoyable practice, despite the person’s background or prior experience.",
                      style: TextStyle(fontSize: 16.0,),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30.0),
              const Text(
                "Why SiLAc?",
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                        color: Colors.deepOrange,
                        width: 2.0,
                      ),
                    ),
                    child: Text(
                      "Gamified",
                      style: TextStyle(fontSize: 16.0,),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                        color: Colors.deepOrange,
                        width: 2.0,
                      ),
                    ),
                    child: Text(
                      "Interactive",
                      style: TextStyle(fontSize: 16.0,),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                        color: Colors.deepOrange,
                        width: 2.0,
                      ),
                    ),
                    child: Text(
                      "Inclusive",
                      style: TextStyle(fontSize: 16.0,),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                        color: Colors.deepOrange,
                        width: 2.0,
                      ),
                    ),
                    child: Text(
                      "Accessible",
                      style: TextStyle(fontSize: 16.0,),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}