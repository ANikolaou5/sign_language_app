import 'package:flutter/material.dart';

import '../classes/user_class.dart';

class LeaderboardList extends StatelessWidget {
  const LeaderboardList({super.key, required this.user, required this.ranking,});

  final UserClass user;
  final int ranking;

  @override
  Widget build(BuildContext context) {
    Color circleColor;

    if (ranking == 1) {
      circleColor = Colors.amber.shade600;
    } else if (ranking == 2) {
      circleColor = Colors.grey.shade400;
    } else if (ranking == 3) {
      circleColor = Colors.brown.shade300;
    } else {
      circleColor = Colors.deepOrange.shade200;
    }

    return Card(
      elevation: ranking <= 3 ? 4.0 : 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            ranking.toString(),
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.username,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user.score.toString(),
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange.shade800,
              ),
            ),
            const Text(
              "points",
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      ),
    );
  }
}