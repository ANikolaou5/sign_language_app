import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String? errorMessage;
  String? name;
  String? surname;
  String? email;
  String? username;
  String? password;

  bool visible = false;
  bool login = false;
  bool loading = false;

  Future<void> _signin() async {
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

    // Saving user in database.
    await userRef.set({
      'accountDetails' : {
        'name': inputName,
        'surname': inputSurname,
        'email': inputEmail,
        'username': inputUsername,
        'password': inputPassword,
      },
      'learningDetails' : {
        'streakNum' : 0,
        'streakNumGoal' : 0,
        'score' : 0,
        'completedLessons' : 0,
      }
    });

    // Saving user info to local storage.
    await _saveUserLocalStorage(inputName, inputSurname, inputEmail, inputUsername, inputPassword);

    setState(() {
      name = inputName;
      surname = inputSurname;
      email = inputEmail;
      username = inputUsername;
      password = inputPassword;
      errorMessage = null;
      loading = false;
    });
  }

  Future<void> _login() async {
    setState(() => loading = true);

    String inputUsername = usernameTextController.text.trim();
    String inputPassword = passwordTextController.text.trim();

    // Forcing user to fill all fields.
    if (inputUsername.isEmpty || inputPassword.isEmpty) {
      setState(() {
        errorMessage = "Enter username and password!";
        loading = false;
      });
      return;
    }

    final DatabaseReference userRef = usersRef.child(inputUsername);
    final DataSnapshot snapshot = await userRef.get();

    // Check if credentials are correct.
    if (!snapshot.exists || snapshot.child('accountDetails/password').value.toString() != inputPassword) {
      setState(() {
        errorMessage = "Invalid username or password!";
        loading = false;
      });
      return;
    }

    // Loading name, surname & email from database.
    String dbName = snapshot.child('accountDetails/name').value.toString();
    String dbSurname = snapshot.child('accountDetails/surname').value.toString();
    String dbEmail = snapshot.child('accountDetails/email').value.toString();

    // Saving user info to local storage.
    await _saveUserLocalStorage(dbName, dbSurname, dbEmail, inputUsername, inputPassword);

    setState(() {
      name = dbName;
      surname = dbSurname;
      email = dbEmail;
      username = inputUsername;
      password = inputPassword;
      errorMessage = null;
      loading = false;
    });
  }

  // Function for logging out.
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();

    // Removing user credentials.
    await prefs.remove('name');
    await prefs.remove('surname');
    await prefs.remove('email');
    await prefs.remove('username');
    await prefs.remove('password');

    setState(() {
      name = null;
      surname = null;
      email = null;
      username = null;
      password = null;
    });
  }

  // Function to load user info from local storage, when already logged in.
  Future<void> _loadUserLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name');
      surname = prefs.getString('surname');
      email = prefs.getString('email');
      username = prefs.getString('username');
      password = prefs.getString('password');
    });
  }

  // Function to save user info to local storage.
  Future<void> _saveUserLocalStorage(String nameInput, String surnameInput, String emailInput, String usernameInput, String passwordInput) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', nameInput);
    await prefs.setString('surname', surnameInput);
    await prefs.setString('email', emailInput);
    await prefs.setString('username', usernameInput);
    await prefs.setString('password', passwordInput);
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
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [BoxShadow(
                    color: Colors.black,
                    blurRadius: 10.0,
                    offset: Offset(2.0, 2.0),
                  )],
                ),
                alignment: Alignment.center,
                child: username == null ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20.0),
                      Center(
                        child: CircleAvatar(
                          radius: 60.0,
                          backgroundColor: Colors.deepPurple.shade300,
                          child: Icon(
                            Icons.person,
                            size: 80.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      TextField(
                          controller: usernameTextController,
                          decoration: const InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder()
                          )
                      ),
                      const SizedBox(height: 10),
                      if (!login)...[
                        TextField(
                            controller: emailTextController,
                            decoration: const InputDecoration(
                                labelText: 'Email',
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
                              onPressed: login ? _login : _signin,
                              child: Text(
                                  login ? 'Log in' : 'Sign in',
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
                                  login ? "Don't have an account?" : "Already have an account?",
                                  style: const TextStyle(fontSize: 16.0)
                              ),
                              TextButton(
                                onPressed: () => setState(() => login = !login),
                                child: Text(
                                    login ? "Sign in" : "Log in",
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
                        backgroundColor: Colors.deepPurple.shade300,
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
                              fontSize: 22,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          username!,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Full Name: ',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                            '$name $surname',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold
                            )
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email: ',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          email!,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(context: context, builder: (BuildContext context) {
                              return AlertDialog(
                                title: Row(
                                  children: [
                                    const SizedBox(width: 10),
                                    Icon(
                                        Icons.warning,
                                        color: Colors.red.shade800,
                                        size: 50
                                    ),
                                    const SizedBox(width: 20),
                                    const Text(
                                      "Log out",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                content: const Text(
                                  "Are you sure you want to log out?",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _logout();
                                      });

                                      Navigator.pop(context);
                                    }, child: const Text('Yes')),
                                  TextButton(
                                    onPressed: () { Navigator.pop(context); },
                                    child: const Text('No'),
                                  ),
                                ],
                              );
                            });
                          },
                          child: const Text(
                              'Log out',
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