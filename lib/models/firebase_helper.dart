import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dev_chat_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseHelper {
  static Future<UserModel?> fetchUserData(String uid) async {
    UserModel? userModel;
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('user').doc(uid).get();
    if (documentSnapshot.data() != null) {
      userModel =
          UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
    }
    return userModel;
  }

  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  static Future<void> firebaseMessagingToken() async {
    print("firebase helper");
    await await fMessaging.requestPermission();
    final fCMToken = await fMessaging.getToken();
    print("token is   ${fCMToken}");
  }
}
