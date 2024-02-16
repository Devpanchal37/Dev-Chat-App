import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dev_chat_app/auth/auth_error.dart';
import 'package:dev_chat_app/component/error_show_widget.dart';
import 'package:dev_chat_app/models/user_model.dart';
import 'package:dev_chat_app/screens/home_page.dart';
import 'package:dev_chat_app/screens/show_auth_error_screen.dart';
import 'package:dev_chat_app/screens/user_sign_up.dart';
import 'package:dev_chat_app/theme/theme.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.initialize("a41c0bac-f06a-4c42-b5dc-858d5890835c");
    print("hell yeahhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh");
// The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    OneSignal.Notifications.requestPermission(true);
    print("successfull");
  }

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  AuthError? authError;

  void checkValue() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty && password.isEmpty) {
      print("enter all field");
      showErrorDialog(context: context, error: "All field required");
    } else if (!EmailValidator.validate(email)) {
      print("enter correct email");
      showErrorDialog(context: context, error: "Enter correct E-mail");
    } else {
      print("all field done");
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async {
    UserCredential? credential;
    showErrorDialog(context: context);
    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (error) {
      authError = AuthError.from(error);
      Navigator.pop(context);
      showAuthErrorDialog(context: context, authError: authError);
      print(error.code.toString());
      // Navigator.pop(context);
      // showErrorDialog(context: context, error: error.code.toString());
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('user').doc(uid).get();
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);
      print("login successfull");
      BuildContext currentContext = context;
      Navigator.pop(context);
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
        backgroundColor: backgroundColor,
        appBar: AppBar(
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
                  "User Login",
                  style: headingStyle,
                ),
                TextField(
                  style: textFieldStyle,
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: "E-mail",
                    hintStyle: textFieldDecorationStyle,
                    contentPadding: EdgeInsets.only(top: 10),
                  ),
                ),
                TextField(
                  style: textFieldStyle,
                  controller: _passwordController,
                  decoration: const InputDecoration(
                      hintText: "Password",
                      hintStyle: textFieldDecorationStyle,
                      contentPadding: EdgeInsets.only(top: 10)),
                ),
                const SizedBox(
                  height: 30,
                ),
                CupertinoButton(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                  onPressed: () {
                    checkValue();
                  },
                  color: backgroundColor,
                  child: const Text(
                    "Log in",
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
                "Don't have account",
                style: textStyle,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserSignUp(),
                        ));
                  },
                  child: Text(
                    "Sign up",
                    style: linkStyle,
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
