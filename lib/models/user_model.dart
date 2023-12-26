class UserModel {
  String? uid;
  String? fullname;
  String? email;
  String? profilePicUrl;

  UserModel({this.uid, this.fullname, this.email, this.profilePicUrl});

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map['uid'];
    fullname = map['fullname'];
    email = map['email'];
    profilePicUrl = map['profilePicUrl'];
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullname": fullname,
      "email": email,
      "profilePicUrl": profilePicUrl,
    };
  }
}
