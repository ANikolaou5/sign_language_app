import 'package:flutter/material.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key, required this.changeIndex});

  final Function(int) changeIndex;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                  children: [
                    const SizedBox(height: 5.0),
                    Container(
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          border: Border.all(width: 2.0)
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Level 1",
                        style: const TextStyle(
                          fontSize: 26.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: List.generate(5, (index) {
                        return Center(
                          child: Container(
                              padding: const EdgeInsets.all(3.0),
                              decoration: BoxDecoration(
                                  color: Colors.green.shade300,
                                  border: Border.all(width: 2.0)
                              ),
                              alignment: Alignment.center,
                              child: TextButton(
                                onPressed: () => widget.changeIndex(1),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Lesson",
                                      style: TextStyle(
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      "${index + 1}",
                                      style: TextStyle(
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 15.0),
                    Container(
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        border: Border.all(width: 2.0)
                      ),
                      alignment: Alignment.center,
                      child: Text(
                          "Level 2",
                          style: const TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                          ),
                        ),
                    ),
                    const SizedBox(height: 15.0),
                    GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: List.generate(5, (index) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.all(3.0),
                            decoration: BoxDecoration(border: Border.all(width: 2.0)),
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: () => widget.changeIndex(1),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Lesson",
                                    style: TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "${index + 1}",
                                    style: TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 15.0),
                    Container(
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          border: Border.all(width: 2.0)
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Level 3",
                        style: const TextStyle(
                          fontSize: 26.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: List.generate(5, (index) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.all(3.0),
                            decoration: BoxDecoration(border: Border.all(width: 2.0)),
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: () => widget.changeIndex(1),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Lesson",
                                    style: TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "${index + 1}",
                                    style: TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
            ),
        )
    );
  }
}