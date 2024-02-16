import 'package:dev_chat_app/auth/auth_error.dart';
import 'package:dev_chat_app/screens/user_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void showAuthErrorDialog(
    {required BuildContext context, required AuthError? authError}) {
  print("auth error screen");
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(authError!.dialogTitle),
        content: Container(
          child: Text(authError.dialogText),
        ),
        actionsPadding: EdgeInsets.zero,
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Ok"))
        ],
      );
    },
  );
}
