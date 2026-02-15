import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../classes/question_class.dart';
import '../classes/reading_tutorial_class.dart';
import 'mcq_widget.dart';
import 'navigation_buttons_widget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

  WebViewController? controller;
  double _webviewHeight = 100;
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

    if (!kIsWeb && widget.readingTutorial.webviewFile != null) {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.orange.shade50)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) async {
              await Future.delayed(const Duration(milliseconds: 100));
              _updateWebViewHeight();
            },
          ),
        )
        ..loadFlutterAsset(widget.readingTutorial.webviewFile!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5.0),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: darkMode ? Colors.black : Colors.orange.shade100,
            border: Border.all(width: 2.0, color: Colors.orange.shade300),
            borderRadius: BorderRadius.circular(15.0),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.tutorial
              ? widget.readingTutorial.tutorialText
              : widget.multipleChoiceQuestion!.question,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 5.0),
        if (!widget.tutorial) ...[
          Text(
            "This question is worth ${widget.questionPoints} points",
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey.shade700,
            ),
          ),
        ],
        const SizedBox(height: 10.0),
        if(widget.tutorial) ...[

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadiusGeometry.circular(10),
              border: Border.all(
                color: Colors.black,
                width: 2
              )
            ),
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(10),
              child: Image.asset(
                widget.readingTutorial.tutorialImage,
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
          ),

          if (widget.readingTutorial.webviewFile != null) ...[
            const SizedBox(height: 20.0),
            kIsWeb
                ? _buildWebFallback()
                : SizedBox(
              height: _webviewHeight,
              child: WebViewWidget(controller: controller!),
            ),
          ],
        ] else ...[
          if (widget.multipleChoiceQuestion != null) ...[
            MultipleChoiceQuestion(
              question: widget.multipleChoiceQuestion!,
              possibleAnswers: widget.possibleAnswers,
              answerIndex: widget.answerIndex,
              check: widget.check,
              darkMode: darkMode,
              onTap: widget.onTap,
              tips: widget.readingTutorial.webviewFile ?? '',
              // 4. Pass null or a dummy check inside MultipleChoiceQuestion if needed
              controller: controller,
              webviewHeight: _webviewHeight,
            ),
          ],
        ],
        const SizedBox(height: 10.0),
        NavigationButtons(answerIndex: widget.answerIndex, isCorrectAnswer: widget.isCorrectAnswer, check: widget.check, darkMode: darkMode, correctAnswer: '', questionPoints: widget.questionPoints, next: widget.next,),
      ],
    );
  }

  // 5. Create a fallback widget for the Web
  Widget _buildWebFallback() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: const Text(
        "Additional tutorial content is available in the mobile app. (Local HTML assets are not supported in web view mode).",
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.black,
        ),
      ),
    );
  }

  // Helper function to calculate and update height
  Future<void> _updateWebViewHeight() async {
    if (kIsWeb || controller == null) return;
    try {
      final result = await controller!.runJavaScriptReturningResult(
          'document.documentElement.scrollHeight');
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