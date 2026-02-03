import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../classes/question_class.dart';
import '../classes/reading_tutorial_class.dart';
import 'mcq_widget.dart';
import 'navigation_buttons_widget.dart';

class BuildTutorial extends StatefulWidget {
  const BuildTutorial({
    super.key,
    required this.tutorial,
    required this.readingTutorial,
    required this.multipleChoiceQuestion,
    required this.tutorialIndex,
    required this.possibleAnswers,
    required this.answerIndex,
    required this.isCorrectAnswer,
    required this.check,
    required this.questionPoints,
    required this.onTap,
    required this.next,
  });

  final bool tutorial;
  final ReadingTutorial readingTutorial;
  final Question? multipleChoiceQuestion;
  final int tutorialIndex;
  final List<String> possibleAnswers;
  final int? answerIndex;
  final bool isCorrectAnswer;
  final bool check;
  final int questionPoints;
  final Function(int) onTap;
  final VoidCallback next;

  @override
  State<BuildTutorial> createState() => _BuildTutorialState();
}

class _BuildTutorialState extends State<BuildTutorial> {

  late WebViewController controller;
  double _webviewHeight = 100;

  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.orange.shade50)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            await Future.delayed(const Duration(milliseconds: 100));

            // 2. Call the resize function
            _updateWebViewHeight();
          },
        ),
      )
      ..loadFlutterAsset('assets/content/A.html');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5.0),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 2.0, color: Colors.orange.shade300),
            borderRadius: BorderRadius.circular(15.0),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.tutorial
              ? widget.readingTutorial.tutorialText
              : widget.multipleChoiceQuestion!.question,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 5.0),
        if (!widget.tutorial) ...[
          Text(
            "This question is worth ${widget.questionPoints} points",
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey.shade700,
            ),
          ),
        ],
        const SizedBox(height: 10.0),
        if(widget.tutorial) ...[
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [BoxShadow(
                color: Colors.orange,
                blurRadius: 2.0,
                offset: Offset(0.5, 0.5),
              )
              ],
            ),
            child: Image.asset(
              widget.readingTutorial.tutorialImage,
              height: 360,
              fit: BoxFit.contain,
            ),
          ),

          SizedBox(height: 20,),

          //WebView
          SizedBox(
            height: _webviewHeight,
            child: WebViewWidget(
              controller: controller,
            ),
          ),

        ] else ...[
          if (widget.multipleChoiceQuestion != null) ...[
            MultipleChoiceQuestion(
              question: widget.multipleChoiceQuestion!,
              possibleAnswers: widget.possibleAnswers,
              answerIndex: widget.answerIndex,
              check: widget.check,
              onTap: widget.onTap,
              tips: '',
            ),
          ],
        ],
        const SizedBox(height: 15.0),
        NavigationButtons(answerIndex: widget.answerIndex, isCorrectAnswer: widget.isCorrectAnswer, check: widget.check, correctAnswer: '', questionPoints: widget.questionPoints, next: widget.next,),
      ],
    );
  }

  // Helper function to calculate and update height
  Future<void> _updateWebViewHeight() async {
    try {
      // Get the scroll height (content height)
      final result = await controller.runJavaScriptReturningResult(
          'document.documentElement.scrollHeight');

      // Strip non-numeric characters to get a clean double.
      String cleanResult = result.toString().replaceAll(RegExp(r'[^0-9.]'), '');

      double? height = double.tryParse(cleanResult);

      if (height != null && height > 0) {
        setState(() {
          _webviewHeight = height + 20;
        });
      }
    } catch (e) {
      debugPrint("Error calculating WebView height: $e");
    }
  }

}