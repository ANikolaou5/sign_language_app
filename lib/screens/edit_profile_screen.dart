import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_language_app/services/general_service.dart';
import '../classes/user_class.dart';
import '../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.user});

  final UserClass user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserService userService = UserService();
  final GeneralService generalService = GeneralService();

  late TextEditingController nameTextController;
  late TextEditingController surnameTextController;
  bool darkMode = true;

  Future<void> _editProfile() async {
    UserClass newUser = widget.user;
    newUser.name = nameTextController.text.trim();
    newUser.surname = surnameTextController.text.trim();

    await userService.editProfile(widget.user);
    await userService.refreshUserLocalStorage();

    generalService.snackBar(context, "Profile updated successfully!", Colors.green.shade300);

    Navigator.pop(context, newUser);
  }

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
    nameTextController = TextEditingController(text: widget.user.name);
    surnameTextController = TextEditingController(text: widget.user.surname);
  }

  @override
  Widget build(BuildContext context) {
    // GaneshTamang (2024). Flutter PopScope for android back button to leave app showing black screen instead of going to home screen of android. [online] GitHub.
    // Available at: https://github.com/GaneshTamang/flast_chat_firebase_example/issues/1
    // [Accessed 3 Dec. 2025].
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              child: Container(
                padding: const EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade100, Colors.white],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Are you sure you want to leave this page?',
                      style: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      "Any changes will not be saved.",
                      style: TextStyle(fontSize: 18.0),
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
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
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
          }
        );
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: darkMode
                      ? [Colors.grey.shade900, Colors.black]
                      : [Colors.orange.shade500, Colors.deepOrange.shade800],
                ),
              ),
            ),
            title: const Text(
              "Edit Profile",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(30.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.deepOrange.shade400,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(30.0),
                    gradient: LinearGradient(
                      colors: darkMode
                        ? [Colors.grey.shade900, Colors.black]
                        : [Colors.orange.shade100, Colors.white],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60.0,
                        backgroundColor: Colors.deepOrange.shade400,
                        child: Icon(
                          Icons.person,
                          size: 70.0,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        widget.user.username,
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25.0),
                TextField(
                  controller: nameTextController,
                  decoration:  InputDecoration(
                    labelText: 'Name',
                    filled: true,
                    fillColor: darkMode ? Colors.black : Colors.white,
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepOrange.shade400,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepOrange.shade400,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: surnameTextController,
                  decoration: InputDecoration(
                    labelText: 'Surname',
                    filled: true,
                    fillColor: darkMode ? Colors.black : Colors.white,
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepOrange.shade400,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.deepOrange.shade400,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25.0),
                ElevatedButton(
                  onPressed: _editProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0),),
                  ),
                  child: Text(
                    'Save',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}