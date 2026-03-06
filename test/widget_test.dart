import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sign_language_app/classes/question_class.dart';
import 'package:sign_language_app/classes/user_class.dart';
import 'package:sign_language_app/screens/account_screen.dart';
import 'package:sign_language_app/screens/read_the_sign_screen.dart';

void main() {
  testWidgets('Clicking an MCQ option highlights the selection.', (WidgetTester tester) async {
    final mockQuestions = [
    Question(
        answer: "No",
        question: "Which word/phrase corresponds to this sign gesture? Tap the correct one.",
        questionContent: "assets/symbols/no.png",
        questionNum: 109,
        questionType: QuestionType.multipleChoiceSignToWords,
        levelNum: null,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: ReadTheSignScreen(
          title: "Read the Sign",
          multipleChoiceQuestions: mockQuestions,
          username: "test1",
          quiz: false,
          timer: false,
          symbols: false,
        ),
      )
    );

    final optionFinder = find.text('No');
    expect(optionFinder, findsOneWidget);
    await tester.tap(optionFinder);
    await tester.pump();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('Profile does not show empty name and surname.', (WidgetTester tester) async {
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

    await tester.pumpWidget(
      MaterialApp(
        home: AccountScreen(
          changeIndex: (index) {},
          onThemeChange: (isDark) {},
        ),
      )
    );

    final nameTextFinder = find.byWidgetPredicate((widget) => widget is Text && widget.data != null && widget.data!.contains(' '),);

    expect(nameTextFinder, findsNothing);
  });
}