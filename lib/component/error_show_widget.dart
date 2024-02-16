import 'package:dev_chat_app/screens/user_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void showErrorDialog(
    {required BuildContext context, String? error, String? signOut}) {
  (error != null && error.isNotEmpty && signOut != null && signOut.isNotEmpty)
      ? showDialog(
          barrierDismissible: true,
          // barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              contentPadding:
                  EdgeInsets.only(left: 25, right: 0, top: 0, bottom: 0),
              actionsPadding: EdgeInsets.zero,
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel")),
                TextButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      OneSignal.Notifications.clearAll();
                      OneSignal.logout();
                      Navigator.popUntil(context, (route) => route.isFirst);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserLogin(),
                          ));
                    },
                    child: Text("sign Out"))
              ],
              // contentPadding: const EdgeInsets.all(40),
              content: Text(error),
              title: Text("Error"),
            );
          },
        )
      : (error != null && error.isNotEmpty)
          ? showDialog(
              // barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Error"),
                  content: Container(
                    child: Text(error),
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
            )
          : showDialog(
              barrierDismissible: false,
              // barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialog(
                  contentPadding: const EdgeInsets.all(40),
                  content: Container(
                    height: 40,
                    width: 40,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              },
            );
}
