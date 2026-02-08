import 'package:flutter/material.dart';
import '../services/general_service.dart';

class TrainCategories extends StatelessWidget {
  const TrainCategories({
    super.key,
    required this.name,
    required this.onTap,
    required this.generalService,
    this.icon = Icons.house,
  });

  final String name;
  final VoidCallback onTap;
  final GeneralService generalService;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 6.0, // Slightly higher elevation for better depth
        shadowColor: Colors.orange.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        clipBehavior: Clip.antiAlias, // Ensures InkWell splash stays inside corners
        child: InkWell(
          splashColor: Colors.orange.shade100,
          onTap: () {
            generalService.startPrompt(context, onTap, Icons.quiz, "Start training?");
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 35.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade500, Colors.deepOrange.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(width: 1.5, color: Colors.orange.shade200),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              children: [
                // Icon inside a soft circular container
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: Colors.deepOrange.shade700,
                  ),
                ),

                const VerticalDivider(
                  width: 20,
                  thickness: 1,
                  indent: 20,
                  endIndent: 0,
                  color: Colors.black,
                ),

                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w800,
                      color: Colors.white
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}