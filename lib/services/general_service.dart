import 'package:flutter/material.dart';

class GeneralService {

  void snackBar(BuildContext context, String text, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Create the options for the sign to text questions based on the lesson number.
  List<String> createOptions(int lessonNum) {
    List<String> options = [];

    if (lessonNum == 1) {
      options = ['A', 'B', 'C', 'D', 'E'];
    } else if (lessonNum == 2) {
      options = ['F', 'G', 'H', 'I', 'J'];
    } else if (lessonNum == 3) {
      options = ['K', 'L', 'M', 'N', 'O'];
    } else if (lessonNum == 4) {
      options = ['P', 'Q', 'R', 'S', 'T'];
    } else if (lessonNum == 5) {
      options = ['U', 'V', 'W', 'X', 'Y', 'Z'];
    } else if (lessonNum == 6) {
      options = ['1', '2', '3', '4', '5'];
    } else if (lessonNum == 7) {
      options = ['6', '7', '8', '9', '10'];
    }

    return options;
  }
}