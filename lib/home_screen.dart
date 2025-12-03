import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.changeIndex});

  final Function(int) changeIndex;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15.0),
                Text(
                  "Welcome!",
                  style: const TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 30.0),
                Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        border: Border.all()
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Streak",
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(width: 2.0),
                                ),
                                child: Text(
                                  "22",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                        ),
                        const SizedBox(height: 10.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Streak Goal",
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(width: 2.0),
                              ),
                              child: Text(
                                "50",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Score",
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(width: 2.0),
                              ),
                              child: Text(
                                "1000",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    )
                ),
                const SizedBox(height: 30.0),
                Container(
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      border: Border.all()
                  ),
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () => widget.changeIndex(1),
                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            "Continue Learning... ",
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Icon(
                            Icons.arrow_circle_right_outlined,
                            size: 30.0,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                ),
                const SizedBox(height: 30.0),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    border: Border.all(),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Leaderboard",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ]
            ),
        ),
    );
  }
}
