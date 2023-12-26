import 'package:dev_chat_app/models/user_model.dart';
import 'package:dev_chat_app/screens/complete_profile_page.dart';
import 'package:dev_chat_app/screens/user_login.dart';
import 'package:dev_chat_app/screens/user_sign_up.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSignUp extends StatefulWidget {
  const UserSignUp({super.key});

  @override
  State<UserSignUp> createState() => _UserSignUpState();
}

class _UserSignUpState extends State<UserSignUp> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  void checkValues() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    RegExp regex =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    if (email.isEmpty && password.isEmpty && confirmPassword.isEmpty) {
      print("enter all value");
    } else if (EmailValidator.validate(email) == false) {
      print("incorrect email value");
    } else if (!regex.hasMatch(password)) {
      print(
          "password must contain one uppercase,one lowercase, one digit, one special character,and atleast 8 character");
    } else if (password != confirmPassword) {
      print("confirm password does not match");
    } else {
      print("successfull");
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (error) {
      print(error.code.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser =
          UserModel(uid: uid, fullname: "", email: email, profilePicUrl: "");
      await FirebaseFirestore.instance
          .collection("user")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return CompleteProfilePage(
                userModel: newUser, user: credential!.user!);
          },
        ));
        print("user firebase successfull");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(9, 38, 53, 1),
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
                  "Sign Up",
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
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(hintText: "Confirm Password"),
                ),
                const SizedBox(
                  height: 30,
                ),
                CupertinoButton(
                  onPressed: () {
                    checkValues();
                    // Navigator.pushReplacement(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => ProfilePage(),
                    //     ));
                  },
                  color: const Color.fromRGBO(9, 38, 53, 1),
                  child: const Text(
                    "Sign Up",
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
                "Already have account",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Log In",
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
