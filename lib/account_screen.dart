import 'package:flutter/material.dart';

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
  /*late TextEditingController usernameTextController;
  late TextEditingController emailTextController;
  late TextEditingController nameTextController;
  late TextEditingController surnameTextController;
  late TextEditingController passwordTextController;*/

  bool visible = false;
  bool login = false;

  /*@override
  void initState() {
    super.initState();
    usernameTextController = TextEditingController();
    emailTextController = TextEditingController();
    nameTextController = TextEditingController();
    surnameTextController = TextEditingController();
    passwordTextController = TextEditingController();
  }*/

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
                child: Column(
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
                          // controller: usernameTextController,
                          decoration: const InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder()
                          )
                      ),
                      const SizedBox(height: 10),
                      if (!login)...[
                        TextField(
                            // controller: emailTextController,
                            decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder()
                            )
                        ),
                        const SizedBox(height: 10),
                        TextField(
                            // controller: nameTextController,
                            decoration: const InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder()
                            )
                        ),
                        const SizedBox(height: 10),
                        TextField(
                            // controller: surnameTextController,
                            decoration: const InputDecoration(
                                labelText: 'Surname',
                                border: OutlineInputBorder()
                            )
                        ),
                        const SizedBox(height: 10),
                      ],
                      TextField(
                        // controller: passwordTextController,
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
                      const SizedBox(height: 40),
                      ElevatedButton(
                          onPressed: () {},
                          child: Text(
                              login ? 'Log in' : 'Register',
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
                                login ? "Register now" : "Log in",
                                style: const TextStyle(
                                    fontSize: 16.0,
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 1.5
                                )
                            ),
                          ),
                        ],
                      ),
                    ]
                ),
              ),
            )
        )
    );
  }
}