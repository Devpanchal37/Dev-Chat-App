import 'package:dev_chat_app/models/firebase_helper.dart';
import 'package:dev_chat_app/models/user_model.dart';
import 'package:dev_chat_app/screens/complete_profile_page.dart';
import 'package:dev_chat_app/screens/home_page.dart';
import 'package:dev_chat_app/screens/user_login.dart';
import 'package:dev_chat_app/screens/user_sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

//we can use anywhere
var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyALKEgCACRuTeo9M4PapbZu2j59uKT8W_A",
          appId: "1:818890965519:android:34caa482312834a268d97a",
          messagingSenderId: "818890965519",
          projectId: "dev-chat-app-9f2ac",
          storageBucket: "dev-chat-app-9f2ac.appspot.com"));
  User? currentUser = FirebaseAuth.instance.currentUser;
  // Logged in if exit
  if (currentUser != null) {
    UserModel? thisUserModel =
        await FirebaseHelper.fetchUserData(currentUser.uid);
    if (thisUserModel != null) {
      print("dataaaaaaaaaaaaaaaa: ${thisUserModel}");
      runApp(UserAlreadyLogin(
          userModel: thisUserModel, firebaseUser: currentUser));
    } else {
      runApp(const MyApp());
    }
  }
  //Not logged in
  else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        // primaryColor: const Color.fromRGBO(9, 38, 53, 1),
        colorScheme: ColorScheme.fromSeed(
            seedColor: Color.fromRGBO(255, 247, 212, 1),
            brightness: Brightness.light
            // const Color.fromRGBO(9, 38, 53, 1),
            ),
        textTheme: const TextTheme(
            displayLarge: TextStyle(
                color: Color.fromRGBO(9, 38, 53, 1),
                fontSize: 40,
                fontWeight: FontWeight.w600)),
      ),
      debugShowCheckedModeBanner: false,
      home: const UserLogin(),
    );
    // UserLogin();
  }
}

class UserAlreadyLogin extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const UserAlreadyLogin(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}
