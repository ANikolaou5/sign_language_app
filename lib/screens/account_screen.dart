import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/user_class.dart';
import '../components/progress_item_widget.dart';
import '../services/user_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key, required this.changeIndex});

  final Function(int) changeIndex;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // Flutter.dev. (2025). Handle changes to a text field. [online]
  // Available at: https://docs.flutter.dev/cookbook/forms/text-field-changes
  // [Accessed 28 Nov. 2025].
  late TextEditingController usernameTextController;
  late TextEditingController emailTextController;
  late TextEditingController nameTextController;
  late TextEditingController surnameTextController;
  late TextEditingController passwordTextController;

  final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
  final FirebaseAuth auth = FirebaseAuth.instance;
  final UserService userService = UserService();

  String? errorMessage;
  UserClass? user;

  bool visible = false;
  bool signIn = true;
  bool loading = false;

  Future<void> _signUp() async {
    setState(() => loading = true);

    String inputName = nameTextController.text.trim();
    String inputSurname = surnameTextController.text.trim();
    String inputEmail = emailTextController.text.trim();
    String inputUsername = usernameTextController.text.trim();
    String inputPassword = passwordTextController.text.trim();

    // Forcing user to fill all fields.
    if (inputName.isEmpty || inputSurname.isEmpty || inputEmail.isEmpty || inputUsername.isEmpty || inputPassword.isEmpty) {
      setState(() {
        errorMessage = "All fields required!";
        loading = false;
      });
      return;
    }

    final DatabaseReference userRef = usersRef.child(inputUsername);
    final DataSnapshot snapshot = await userRef.get();

    // Check if username exists.
    if (snapshot.exists) {
      setState(() {
        errorMessage = "Username already exists!";
        loading = false;
      });
      return;
    }

    // Firebase. (n.d.). Authenticate with Firebase using Password-Based Accounts on Flutter | Firebase Documentation. [online]
    // Available at: https://firebase.google.com/docs/auth/flutter/password-auth
    // [Accessed 19 Jan. 2026].
    // firebase.flutter.dev. (n.d.). Using Firebase Authentication | FlutterFire. [online]
    // Available at: https://firebase.flutter.dev/docs/auth/usage/
    // [Accessed 19 Jan. 2026].
    try {
      UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: emailTextController.text.trim(),
        password: passwordTextController.text.trim(),
      );

      // Saving user in database.
      await userRef.set({
        'accountDetails' : {
          'uid': credential.user!.uid,
          'name': inputName,
          'surname': inputSurname,
          'email': inputEmail,
          'username': inputUsername,
        },
        'learningDetails' : {
          'streakNum' : 0,
          'streakNumGoal' : 0,
          'lastStreakDate': '',
          'score' : 0,
          'completedLevels' : 0,
        },
        'gameStats' : {
          'draws' : 0,
          'losses' : 0,
          'wins' : 0,
        }
      });

      final newUser = UserClass(
        uid: credential.user!.uid,
        name: inputName,
        surname: inputSurname,
        email: inputEmail,
        username: inputUsername,
        streakNum: 0,
        streakNumGoal: 0,
        score: 0,
        completedLevels: 0,
        draws: 0,
        losses: 0,
        wins: 0,
        badges: [],
        completedLessons: [],
      );

      // Saving user info to local storage.
      await userService.saveUserLocalStorage(newUser);

      setState(() {
        user = newUser;
        errorMessage = null;
        loading = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
        loading = false;
      });
    }
  }

  Future<void> _signIn() async {
    setState(() => loading = true);

    String inputEmail = emailTextController.text.trim();
    String inputPassword = passwordTextController.text.trim();

    // Forcing user to fill all fields.
    if (inputEmail.isEmpty || inputPassword.isEmpty) {
      setState(() {
        errorMessage = "Enter email and password!";
        loading = false;
      });
      return;
    }

    // Firebase. (n.d.). Authenticate with Firebase using Password-Based Accounts on Flutter | Firebase Documentation. [online]
    // Available at: https://firebase.google.com/docs/auth/flutter/password-auth
    // [Accessed 19 Jan. 2026].
    // firebase.flutter.dev. (n.d.). Using Firebase Authentication | FlutterFire. [online]
    // Available at: https://firebase.flutter.dev/docs/auth/usage/
    // [Accessed 19 Jan. 2026].
    try {
      UserCredential credential = await auth.signInWithEmailAndPassword(
        email: emailTextController.text.trim(),
        password: passwordTextController.text.trim(),
      );

      final snapshot = await usersRef
          .orderByChild('accountDetails/uid')
          .equalTo(credential.user!.uid)
          .get();

      if (snapshot.exists) {
        final Map<dynamic, dynamic> result = snapshot.value as Map;
        String username = result.keys.first.toString();
        Map<String, dynamic> data = Map<String, dynamic>.from(result[username]);
        final dbUser = UserClass.fromFirebase(username, data);

        // Saving user info to local storage.
        await userService.saveUserLocalStorage(dbUser);

        setState(() {
          user = dbUser;
          errorMessage = null;
          loading = false;
        });
      }
    } on FirebaseAuthException {
      setState(() {
        errorMessage = "Invalid email or password.";
        loading = false;
      });
    }
  }

  // Function for signing out.
  Future<void> _signOut() async {
    // firebase.flutter.dev. (n.d.). Using Firebase Authentication | FlutterFire. [online]
    // Available at: https://firebase.flutter.dev/docs/auth/usage/
    // [Accessed 19 Jan. 2026].
    await auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    setState(() {
      user = null;
      usernameTextController.clear();
      emailTextController.clear();
      nameTextController.clear();
      surnameTextController.clear();
      passwordTextController.clear();
    });
  }

  // Function to load user info from local storage, when already signed in.
  Future<void> _loadUserLocalStorage() async {
    user = await userService.loadUserLocalStorage();

    if (user != null) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    usernameTextController = TextEditingController();
    emailTextController = TextEditingController();
    nameTextController = TextEditingController();
    surnameTextController = TextEditingController();
    passwordTextController = TextEditingController();

    _loadUserLocalStorage();
  }

  @override
  void dispose() {
    usernameTextController.dispose();
    emailTextController.dispose();
    nameTextController.dispose();
    surnameTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.orange.shade50,
        body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.deepOrange.shade400,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(30.0),
                      gradient: LinearGradient(colors: [Colors.orange.shade100, Colors.white],),
                    ),
                    alignment: Alignment.center,
                    child: user == null ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20.0),
                        Center(
                          child: CircleAvatar(
                            radius: 60.0,
                            backgroundColor: Colors.deepOrange.shade400,
                            child: Icon(
                              Icons.person,
                              size: 70.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        TextField(
                          controller: emailTextController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.deepOrange.shade400,
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (!signIn)...[
                          TextField(
                            controller: usernameTextController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.deepOrange.shade400,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: nameTextController,
                            decoration:  InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.deepOrange.shade400,
                                  width: 2.0,
                                ),
                              ),
                            )
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: surnameTextController,
                            decoration: InputDecoration(
                              labelText: 'Surname',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.deepOrange.shade400,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        TextField(
                          controller: passwordTextController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.deepOrange.shade400,
                                width: 2.0,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(visible ? Icons.visibility : Icons.visibility_off,),
                              onPressed: () {
                                setState(() {
                                  visible = !visible;
                                });
                              },
                            ),
                          ),
                          obscureText: !visible,
                        ),
                        const SizedBox(height: 10),
                        if (errorMessage != null) Text(errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        loading ? const Center(child: CircularProgressIndicator()) : Column(
                          children: [
                            ElevatedButton(
                              onPressed: signIn ? _signIn : _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0),),
                              ),
                              child: Text(
                                signIn ? 'Sign in' : 'Sign up',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    signIn ? "Don't have an account?" : "Already have an account?",
                                    style: const TextStyle(fontSize: 16.0)
                                ),
                                TextButton(
                                  onPressed: () {
                                    usernameTextController.clear();
                                    emailTextController.clear();
                                    nameTextController.clear();
                                    surnameTextController.clear();
                                    passwordTextController.clear();

                                    setState(() {
                                      errorMessage = null;
                                      signIn = !signIn;
                                    });
                                  },
                                  child: Text(
                                    signIn ? "Sign up" : "Sign in",
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      decoration: TextDecoration.underline,
                                      decorationThickness: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ]
                    ) : Center(
                      child: Column (
                        children: [
                          const SizedBox(height: 10.0),
                          CircleAvatar(
                            radius: 40.0,
                            backgroundColor: Colors.deepOrange.shade400,
                            child: Icon(
                              Icons.person,
                              size: 50.0,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            user!.username,
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${user!.name} ${user!.surname}',
                            style: const TextStyle(fontSize: 14.0),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            user!.email!,
                            style: const TextStyle(fontSize: 14.0,),
                          ),
                          const SizedBox(height: 5.0),
                          Divider(color: Colors.deepOrange.shade400),
                          const SizedBox(height: 5.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ProgressItem(text: "Streak", num: user?.streakNum ?? 0),
                              ProgressItem(text: "Streak Goal", num: user?.streakNumGoal ?? 0),
                              ProgressItem(text: "Score", num: user?.score ?? 0),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                        ],
                      ),
                    ),
                  ),
                  if (user != null) ...[
                    const SizedBox(height: 10.0),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.person_outlined,
                                size: 25.0,
                                color: Colors.deepOrange.shade800,
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            const Text(
                              "Edit Profile",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.dark_mode_outlined,
                                size: 25.0,
                                color: Colors.deepOrange.shade800,
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            const Text(
                              "Appearance",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.help_outline,
                                size: 25.0,
                                color: Colors.deepOrange.shade800,
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            const Text(
                              "Help & Support",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    InkWell(
                      onTap: () {
                        showDialog(context: context, builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                            child: Container(
                              padding: const EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25.0),
                                gradient: LinearGradient(colors: [Colors.orange.shade100, Colors.white],),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.warning,
                                        color: Colors.red.shade800,
                                        size: 40.0,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        "Sign out",
                                        style: const TextStyle(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10.0),
                                  const Text(
                                    "Are you sure you want to sign out?",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange.shade700,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                        ),
                                        onPressed: () async {
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          "No",
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _signOut();
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          "Yes",
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(
                            color: Colors.red.shade200,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.logout,
                                size: 25.0,
                                color: Colors.deepOrange.shade800,
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            const Text(
                              "Sign out",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            )
        )
    );
  }
}