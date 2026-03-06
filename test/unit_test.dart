import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/classes/user_class.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // Password match on sign up.
  test('Password and confirm password match during signing up.', () {
    String password = "123456";
    String confirmPassword = "123456";
    bool matches = (password == confirmPassword && password.isNotEmpty);

    expect(matches, true);
  });

  // Password mismatch on sign up.
  test('Password and confirm password mismatch during signing up.', () {
    String password = "123456";
    String confirmPassword = "123123";
    String? errorMessage;
    bool matches = (password == confirmPassword && password.isNotEmpty);

    if (password != confirmPassword) {
      errorMessage = "Passwords do not match";
    }

    expect(matches, false);
    expect(errorMessage, "Passwords do not match");
  });

  test('Sign up with an already existing user. ', () {
    // Mock database usernames.
    final List<String> usernames = ['test1', 'test2', 'devUser'];
    // Input username that already exists.
    String inputUsername = 'test2';
    bool exists = usernames.contains(inputUsername);
    String? errorMessage;

    if (exists) {
      errorMessage = "Username already exists!";
    }

    expect(exists, true);
    expect(errorMessage, "Username already exists!");
  });

  // Badges sorting logic.
  test('Badges earned sorted first.', () {
    // Badge 1: isEarned = false
    // Badge 2: isEarned = true
    List<Map<String, dynamic>> badges = [
      {'id': 1, 'earned': false},
      {'id': 2, 'earned': true},
    ];

    badges.sort((a, b) {
      if (a['isEarned'] && !b['isEarned']) return -1;
      if (!a['isEarned'] && b['isEarned']) return 1;
      return 0;
    });

    expect(badges[0]['id'], 2); // The earned badge should appear first.
  });

  // Duplicate badges prevention.
  test('Check if a badge is awarded to user more than once if triggered again.', () {
    List<int> userBadges = [1, 2];
    int newBadge = 2; // "Numbers 1-10" triggered again.

    if (!userBadges.contains(newBadge)) {
      userBadges.add(newBadge);
    }

    expect(userBadges.length, 2); // Length should not change.
  });

  // Theme persistence.
  test('Theme (dark/light mode) saving.', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', true);
    final isDark = prefs.getBool('darkMode');

    expect(isDark, true);
  });

  // Avatar updates in the database.
  test('Edit avatar.', () {
    final user = UserClass(avatar: "Jonny", uid: '1234567890', username: 'test', streakNum: 0, score: 0, completedLevels: 0, dragAndDropQCount: 0, imgToWordQCount: 0, readTheSignQCount: 0, signToWordsQCount: 0, wordsToSignQCount: 0, dragAndDropTCount: 0, imgToWordTCount: 0, readTheSignTCount: 0, signToWordsTCount: 0, wordsToSignTCount: 0);
    String newAvatar = "Aria";

    // New avatar selection.
    user.avatar = newAvatar;
    expect(user.avatar, "Aria");
  });

  // Optional name display logic.
  test('Optional name and surname.', () {
    String name = "";
    String surname = "";

    // Both name and surname are empty, so this string must also be empty.
    String displayName = (name.isEmpty && surname.isEmpty) ? "" : "$name $surname";

    expect(displayName, "");
  });

  // MCQ empty selection.
  test('No answer selected in an MCQ.', () {
    int? selectedIndex; // If nothing selected then null.

    bool next() {
      return selectedIndex != null;
    }

    // Nothing selected.
    expect(next(), false);

    // An answer selected.
    selectedIndex = 1;
    expect(next(), true);
  });

  // Matching logic.
  test('Not all items matched in a matching question.', () {
    int totalItems = 3;
    int matchedItems = 2;

    bool complete = matchedItems == totalItems;
    expect(complete, false);
  });
}