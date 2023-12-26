import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dev_chat_app/models/user_model.dart';
import 'package:dev_chat_app/screens/home_page.dart';
import 'package:dev_chat_app/screens/user_sign_up.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void checkValue() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty && password.isEmpty) {
      print("enter all field");
    } else if (!EmailValidator.validate(email)) {
      print("enetr correct email");
    } else {
      print("all field done");
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (error) {
      print(error.code.toString());
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('user').doc(uid).get();
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);
      print("login successfull");
      BuildContext currentContext = context;
      Navigator.pushReplacement(
          currentContext,
          MaterialPageRoute(
            builder: (context) =>
                HomePage(userModel: userModel, firebaseUser: credential!.user!),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(9, 38, 53, 1),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(158, 200, 185, 1),
          title: const Text(
            "Chat App",
            style: TextStyle(
                color: Color.fromRGBO(9, 38, 53, 1),
                fontSize: 40,
                fontWeight: FontWeight.w600),
          ),
        ),
        body: Center(
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(158, 200, 185, 1),
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  "Log In",
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(9, 38, 53, 1)),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(hintText: "E-mail"),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(hintText: "Password"),
                ),
                const SizedBox(
                  height: 30,
                ),
                CupertinoButton(
                  onPressed: () {
                    checkValue();
                  },
                  color: const Color.fromRGBO(9, 38, 53, 1),
                  child: const Text(
                    "Log in",
                    style: TextStyle(color: Color.fromRGBO(158, 200, 185, 1)),
                  ),
                ),
                const SizedBox(
                  height: 30,
                )
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          color: const Color.fromRGBO(158, 200, 185, 1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have account",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserSignUp(),
                        ));
                  },
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Color.fromRGBO(9, 38, 53, 1)),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
