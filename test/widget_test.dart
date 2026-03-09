import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sign_language_app/classes/question_class.dart';
import 'package:sign_language_app/classes/user_class.dart';
import 'package:sign_language_app/components/mcq_widget.dart';
import 'package:sign_language_app/components/progress_item_widget.dart';
import 'package:sign_language_app/screens/account_screen.dart';

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupFirebaseCoreMocks();
}

void main() {
  setupFirebaseMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('Account Screen does not show empty name and surname.', (WidgetTester tester) async {
    final emptyUser = UserClass(
      uid: "1234567890",
      username: "test1",
      email: "test1@test.com",
      name: "",
      surname: "",
      avatar: "Jonny",
      streakNum: 0,
      score: 0,
      completedLevels: 0,
      dragAndDropQCount: 0,
      imgToWordQCount: 0,
      readTheSignQCount: 0,
      signToWordsQCount: 0,
      wordsToSignQCount: 0,
      dragAndDropTCount: 0,
      imgToWordTCount: 0,
      readTheSignTCount: 0,
      signToWordsTCount: 0,
      wordsToSignTCount: 0,
    );

    await tester.pumpWidget(MaterialApp(
      home: AccountScreen(
        changeIndex: (index) {},
        onThemeChange: (isDark) {},
      ),
    ));

    await tester.pumpAndSettle();
    final nameTextFinder = find.byWidgetPredicate(
          (widget) => widget is Text && widget.data == " ",
    );

    expect(nameTextFinder, findsNothing);
  });

  testWidgets('ProgressItem displays correct data.', (WidgetTester tester) async {
    final user = UserClass(
      uid: "1234567890",
      username: "test1",
      email: "test1@test.com",
      name: "",
      surname: "",
      avatar: "Jonny",
      streakNum: 0,
      score: 90,
      completedLevels: 0,
      dragAndDropQCount: 0,
      imgToWordQCount: 0,
      readTheSignQCount: 0,
      signToWordsQCount: 0,
      wordsToSignQCount: 0,
      dragAndDropTCount: 0,
      imgToWordTCount: 0,
      readTheSignTCount: 0,
      signToWordsTCount: 0,
      wordsToSignTCount: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProgressItem(
            text: "Total\nScore",
            num: user.score,
            icon: Icons.emoji_events,
          ),
        ),
      ),
    );

    expect(find.text('90'), findsOneWidget);
    expect(find.text('Total\nScore'), findsOneWidget);
    expect(find.byIcon(Icons.emoji_events), findsOneWidget);
  });

  testWidgets('MultipleChoiceQuestion shows check icon for correct answer.', (WidgetTester tester) async {
    final mockQuestion = Question(
      answer: "assets/conv/hello.png",
      question: "Which sign corresponds to this fingerspelling phrase? Tap the correct one.",
      questionContent: "Hello",
      questionNum: 37,
      questionType: QuestionType.multipleChoice,
      levelNum: 3,
    );

    final possibleAnswers = ["assets/conv/hello.png", "assets/conv/goodbye.png", "assets/conv/thankYou.png"];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MultipleChoiceQuestion(
              question: mockQuestion,
              possibleAnswers: possibleAnswers,
              answerIndex: 0,
              check: true,
              darkMode: false,
              onTap: (index) {},
              tips: "",
              controller: null,
              webviewHeight: 100,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.text("Hello"), findsOneWidget);
  });
}