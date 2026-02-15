import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/screens/appearance_screen.dart';
import 'package:sign_language_app/screens/edit_profile_screen.dart';

import '../classes/user_class.dart';
import '../components/progress_item_widget.dart';
import '../services/user_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key, required this.changeIndex, required this.onThemeChange,});

  final Function(int) changeIndex;
  final Function(bool) onThemeChange;
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
  late TextEditingController confirmPasswordTextController;

  final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
  final FirebaseAuth auth = FirebaseAuth.instance;
  final UserService userService = UserService();

  String? errorMessage;
  UserClass? user;

  bool visible1 = false;
  bool visible2 = false;
  bool signIn = true;
  bool loading = false;
  bool darkMode = true;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _signUp() async {
    setState(() => loading = true);

    String inputName = nameTextController.text.trim();
    String inputSurname = surnameTextController.text.trim();
    String inputEmail = emailTextController.text.trim();
    String inputUsername = usernameTextController.text.trim();
    String inputPassword = passwordTextController.text.trim();
    String inputConfirmPassword = confirmPasswordTextController.text.trim();

    // Forcing user to fill all fields.
    if (inputEmail.isEmpty || inputUsername.isEmpty || inputPassword.isEmpty) {
      setState(() {
        errorMessage = "Email, username and password fields required!";
        loading = false;
      });
      return;
    }

    if (inputPassword != inputConfirmPassword) {
      setState(() {
        errorMessage = "Passwords do not match";
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
          'lastStreakDate': '',
          'score' : 0,
          'completedLevels' : 0,
          'quizCounts' : {
            "dragAndDropQCount": 0,
            "imgToWordQCount": 0,
            "readTheSignQCount": 0,
            "signToWordsQCount": 0,
            "wordsToSignQCount": 0,
          },
          'trainCounts' : {
            "dragAndDropTCount": 0,
            "imgToWordTCount": 0,
            "readTheSignTCount": 0,
            "signToWordsTCount": 0,
            "wordsToSignTCount": 0,
          }
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
        score: 0,
        completedLevels: 0,
        draws: 0,
        losses: 0,
        wins: 0,
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
    widget.onThemeChange(false);

    setState(() {
      user = null;
      usernameTextController.clear();
      emailTextController.clear();
      nameTextController.clear();
      surnameTextController.clear();
      passwordTextController.clear();
      confirmPasswordTextController.clear();
      _loadTheme();
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

    _loadTheme();
    usernameTextController = TextEditingController();
    emailTextController = TextEditingController();
    nameTextController = TextEditingController();
    surnameTextController = TextEditingController();
    passwordTextController = TextEditingController();
    confirmPasswordTextController = TextEditingController();
    _loadUserLocalStorage();
  }

  @override
  void dispose() {
    usernameTextController.dispose();
    emailTextController.dispose();
    nameTextController.dispose();
    surnameTextController.dispose();
    passwordTextController.dispose();
    confirmPasswordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black38,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(30.0),
                    gradient: LinearGradient(
                      colors: darkMode
                          ? [Colors.grey.shade900, Colors.black]
                          : [Colors.orange.shade500, Colors.deepOrange.shade800],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: user == null ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20.0),
                      Center(
                        child: CircleAvatar(
                          radius: 60.0,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 70.0,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      TextField(
                        style: TextStyle(color: Colors.white),
                        controller: emailTextController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 3.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white60,
                              width: 2,
                            )
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (!signIn)...[
                        TextField(
                          controller: usernameTextController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 3.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white60,
                                  width: 2,
                                )
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: nameTextController,
                          style: TextStyle(color: Colors.white),
                          decoration:  InputDecoration(
                            labelText: 'Name (Optional)',
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 3.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white60,
                                  width: 2,
                                )
                            ),
                          )
                        ),
                        const SizedBox(height: 10.0),
                        TextField(
                          controller: surnameTextController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Surname (Optional)',
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 3.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white60,
                                  width: 2,
                                )
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                      ],
                      TextField(
                        controller: passwordTextController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 3.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white60,
                                width: 2,
                              )
                          ),
                          suffixIcon: IconButton(
                            color: Colors.white,
                            icon: Icon(visible1 ? Icons.visibility : Icons.visibility_off,),
                            onPressed: () {
                              setState(() {
                                visible1 = !visible1;
                              });
                            },
                          ),
                        ),
                        obscureText: !visible1,
                      ),
                      if (!signIn)...[
                        const SizedBox(height: 10.0),
                        TextField(
                          controller: confirmPasswordTextController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 3.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white60,
                                  width: 2,
                                )
                            ),
                            suffixIcon: IconButton(
                              color: Colors.white,
                              icon: Icon(visible2 ? Icons.visibility : Icons.visibility_off,),
                              onPressed: () {
                                setState(() {
                                  visible2 = !visible2;
                                });
                              },
                            ),
                          ),
                          obscureText: !visible2,
                        ),
                      ],
                      const SizedBox(height: 10.0),
                      if (errorMessage != null) Text(errorMessage!, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      loading ? const Center(child: CircularProgressIndicator(color: Colors.white,)) : Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: signIn ? _signIn : _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0),),
                              ),
                              child: Text(
                                signIn ? 'Sign in' : 'Sign up',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 50,),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  signIn ? "Don't have an account?" : "Already have an account?",
                                  style: const TextStyle(fontSize: 16.0, color: Colors.white)
                              ),
                              SizedBox(height: 10,),
                              OutlinedButton(
                                style: ButtonStyle(
                                  side: MaterialStateProperty.all(BorderSide(color: Colors.white, width: 1.0)),
                                ),
                                onPressed: () {
                                  usernameTextController.clear();
                                  emailTextController.clear();
                                  nameTextController.clear();
                                  surnameTextController.clear();
                                  passwordTextController.clear();
                                  confirmPasswordTextController.clear();

                                  setState(() {
                                    errorMessage = null;
                                    signIn = !signIn;
                                  });
                                },
                                child: Text(
                                  signIn ? "Sign up" : "Sign in",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ]
                  ) : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column (
                        children: [
                          CircleAvatar(
                            radius: 40.0,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 50.0,
                              color: Colors.deepOrange.shade800,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            '${user!.username}',
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (user!.name != '' || user!.surname != '') ...[
                            Text(
                              '${user!.name} ${user!.surname}',
                              style: const TextStyle(fontSize: 14.0, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 5.0),
                          Text(
                            user!.email!,
                            style: const TextStyle(fontSize: 14.0, color: Colors.white),
                          ),
                          const SizedBox(height: 5.0),
                          Divider(color: Colors.white,),
                          const SizedBox(height: 5.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ProgressItem(
                                condensed: true,
                                text: "Game\nStreak",
                                num: user?.streakNum ?? 0,
                                icon: Icons.local_fire_department,
                              ),
                              ProgressItem(
                                condensed: true,
                                text: "Total\nScore",
                                num: user?.score ?? 0,
                                icon: Icons.emoji_events,
                              ),
                              ProgressItem(
                                condensed: true,
                                text: "Online\nWins",
                                num: user?.wins ?? 0,
                                icon: Icons.videogame_asset_rounded,
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
                if (user != null) ...[
                  const SizedBox(height: 5.0),
                  InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfileScreen(user: user!)),
                      );
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: darkMode ? Colors.black : Colors.white,
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AppearanceScreen(onThemeChange: widget.onThemeChange)),
                      );
                      setState(() {
                        _loadTheme();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: darkMode ? Colors.black : Colors.white,
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  InkWell(
                    onTap: () {
                      showDialog(context: context, builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                          child: Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              gradient: LinearGradient(
                                colors: darkMode
                                  ? [Colors.grey.shade900, Colors.black]
                                  : [Colors.orange.shade100, Colors.white],
                              ),
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
                                        backgroundColor: Colors.deepOrange,
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
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
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
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: darkMode ? Colors.black : Colors.red.shade50,
                        border: Border.all(
                          color: Colors.red.shade200,
                          width: 3.0,
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
        ),
      )
    );
  }
}