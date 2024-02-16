import 'package:dev_chat_app/auth/auth_error.dart';
import 'package:dev_chat_app/component/error_show_widget.dart';
import 'package:dev_chat_app/models/user_model.dart';
import 'package:dev_chat_app/screens/complete_profile_page.dart';
import 'package:dev_chat_app/screens/show_auth_error_screen.dart';
import 'package:dev_chat_app/screens/user_login.dart';
import 'package:dev_chat_app/screens/user_sign_up.dart';
import 'package:dev_chat_app/theme/theme.dart';
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
  AuthError? authError;
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
      showErrorDialog(
        context: context,
        error: "Enter All Field",
      );
    } else if (EmailValidator.validate(email) == false) {
      print("incorrect email value");
      showErrorDialog(context: context, error: "Incorrect email value");
    } else if (!regex.hasMatch(password)) {
      print(
          "password must contain one uppercase,one lowercase, one digit, one special character,and atleast 8 character");
      showErrorDialog(
          context: context,
          error:
              "password must contain one uppercase,one lowercase, one digit, one special character,and atleast 8 character");
    } else if (password != confirmPassword) {
      print("confirm password does not match");
      showErrorDialog(
          context: context, error: "Confirm password does not match");
    } else {
      print("successfull");
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    showErrorDialog(context: context);
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      print("credential isssssssss : ${credential}");
    } on FirebaseAuthException catch (error) {
      Navigator.pop(context);
      authError = AuthError.from(error);
      showAuthErrorDialog(context: context, authError: authError);

      print(error.code.toString());
    }

    if (credential != null) {
      print("helllllllloooooooooooo");
      String uid = credential.user!.uid;
      UserModel newUser =
          UserModel(uid: uid, fullname: "", email: email, profilePicUrl: "");
      await FirebaseFirestore.instance
          .collection("user")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        Navigator.popUntil(context, (route) => route.isFirst);
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
        backgroundColor: backgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: appBarColor,
          title: const Text(
            "Chat App",
            style: titleStyle,
          ),
        ),
        body: Center(
          child: Container(
            decoration: BoxDecoration(
              color: appBarColor,
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
                  style: headingStyle,
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      hintText: "E-mail", hintStyle: textFieldDecorationStyle),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                      hintText: "Password",
                      hintStyle: textFieldDecorationStyle),
                ),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                      hintText: "Confirm Password",
                      hintStyle: textFieldDecorationStyle),
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
                  color: backgroundColor,
                  child: const Text(
                    "Sign Up",
                    style: buttonStyle,
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
          color: appBarColor,
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
                  child: Text(
                    "Log In",
                    style: linkStyle,
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
