import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/user_class.dart';

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

  String? errorMessage;
  UserClass? user;

  bool visible = false;
  bool signIn = false;
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
          'score' : 0,
          'completedLessons' : 0,
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
        completedLessons: 0,
      );

      // Saving user info to local storage.
      await _saveUserLocalStorage(newUser);

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
        await _saveUserLocalStorage(dbUser);

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
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username == null) return;

    setState(() {
      user = UserClass(
        uid: prefs.getString('uid') ?? '',
        username: username,
        name: prefs.getString('name'),
        surname: prefs.getString('surname'),
        email: prefs.getString('email'),
        streakNum: prefs.getInt('streakNum') ?? 0,
        streakNumGoal: prefs.getInt('streakNumGoal') ?? 0,
        score: prefs.getInt('score') ?? 0,
        completedLessons: prefs.getInt('completedLessons') ?? 0,
      );
    });
  }

  // Function to save user info to local storage.
  Future<void> _saveUserLocalStorage(UserClass user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('username', user.username);
    await prefs.setString('uid', user.uid);
    if (user.name != null) await prefs.setString('name', user.name!);
    if (user.surname != null) await prefs.setString('surname', user.surname!);
    if (user.email != null) await prefs.setString('email', user.email!);
    await prefs.setInt('streakNum', user.streakNum);
    await prefs.setInt('streakNumGoal', user.streakNumGoal);
    await prefs.setInt('score', user.score);
    await prefs.setInt('completedLessons', user.completedLessons);
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
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.orange.shade50,
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [BoxShadow(
                    color: Colors.black,
                    blurRadius: 8.0,
                    offset: Offset(0.5, 0.5),
                  )],
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
                            size: 80.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      TextField(
                          controller: emailTextController,
                          decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder()
                          )
                      ),
                      const SizedBox(height: 10),
                      if (!signIn)...[
                        TextField(
                            controller: usernameTextController,
                            decoration: const InputDecoration(
                                labelText: 'Username',
                                border: OutlineInputBorder()
                            )
                        ),
                        const SizedBox(height: 10),
                        TextField(
                            controller: nameTextController,
                            decoration: const InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder()
                            )
                        ),
                        const SizedBox(height: 10),
                        TextField(
                            controller: surnameTextController,
                            decoration: const InputDecoration(
                                labelText: 'Surname',
                                border: OutlineInputBorder()
                            )
                        ),
                        const SizedBox(height: 10),
                      ],
                      TextField(
                        controller: passwordTextController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
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
                      const SizedBox(height: 40),
                      loading ? const Center(child: CircularProgressIndicator()) : Column(
                        children: [
                          ElevatedButton(
                              onPressed: signIn ? _signIn : _signUp,
                              child: Text(
                                  signIn ? 'Sign in' : 'Sign up',
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  )
                              )
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
                                        decorationThickness: 1.5
                                    )
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ]
                ) : Column (
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: CircleAvatar(
                        radius: 60.0,
                        backgroundColor: Colors.deepOrange.shade400,
                        child: Icon(
                          Icons.person,
                          size: 80.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Username: ',
                          style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          user!.username,
                          style: const TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Full Name: ',
                          style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                            '${user!.name} ${user!.surname}',
                            style: const TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold
                            )
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email: ',
                          style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          user!.email!,
                          style: const TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    Center(
                        child: ElevatedButton(
                          onPressed: () {
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
                                            size: 50,
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
                          child: const Text(
                              'Sign out',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              )
                          ),
                        )
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            )
        )
    );
  }
}