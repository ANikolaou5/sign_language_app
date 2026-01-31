import 'package:flutter/material.dart';

import '../services/general_service.dart';

class TrainCategories extends StatelessWidget {
  const TrainCategories({super.key, required this.name, required this.onTap, required this.generalService,});

  final String name;
  final VoidCallback onTap;
  final GeneralService generalService;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () {
          generalService.startPrompt(context, onTap, Icons.quiz, "Start training?");
        },
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Container(
            padding: const EdgeInsets.all(49.0),
            decoration: BoxDecoration(
              color: Colors.deepOrange.shade200,
              border: Border.all(width: 2.0, color: Colors.orange.shade300),
              borderRadius: BorderRadius.circular(15.0),
            ),
            alignment: Alignment.center,
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange.shade800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}