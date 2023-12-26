import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dev_chat_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
}
