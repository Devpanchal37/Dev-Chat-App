import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dev_chat_app/component/error_show_widget.dart';
import 'package:dev_chat_app/models/user_model.dart';
import 'package:dev_chat_app/screens/home_page.dart';
import 'package:dev_chat_app/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfilePage extends StatefulWidget {
  final UserModel userModel;
  final User user;

  const CompleteProfilePage(
      {super.key, required this.userModel, required this.user});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  TextEditingController _userNameController = TextEditingController();
  File? imageFile;

  void cropImage(XFile file) async {
    final croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 20);
    print(
        "helllllllllllllllooooooooooooooooooooooooooooooooooooooooooooooooooo:      :${croppedFile}");
    if (croppedFile != null) {
      print("iffffffffffffffffffffffffffffffffffffffffffffffffffff");
      imageFile = File(croppedFile.path);
      print("helllllllllllllllloloooooooooooooooooooooo");
      print("croppppppppppppppppppppppppppppp:${imageFile}");

      setState(() {});
    }
  }

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      print("selectttttttttttttttttttttttttttttttttttt:       ${pickedFile}");
      cropImage(pickedFile);
    }
  }

  void showPhotoOption() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Image"),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                    title: const Text("Gallery"),
                    trailing: const Icon(Icons.house_outlined),
                    onTap: () {
                      Navigator.pop(context);
                      selectImage(ImageSource.gallery);
                    }),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  title: const Text("camera"),
                  trailing: const Icon(Icons.camera_alt_outlined),
                )
              ],
            )
          ],
        );
      },
    );
  }

  void checkValues() {
    print("func run");
    String userName = _userNameController.text;
    if (userName.isEmpty && imageFile == null) {
      showErrorDialog(context: context, error: "Complete all field");
      print("enter all field");
      log("enter all field");
    } else {
      uploadData();
    }
  }

  void uploadData() async {
    showErrorDialog(context: context);
    print("upload data runnn");
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);
    print("upload task run      hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh");
    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    String fullName = _userNameController.text;

    widget.userModel.fullname = fullName;
    widget.userModel.profilePicUrl = imageUrl;
    await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then(
      (value) {
        Navigator.popUntil(context, (route) => route.isFirst);

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                  userModel: widget.userModel, firebaseUser: widget.user),
            ));
      },
    );
    print("hureeyyy ... data uploadedddd");
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
        body: Container(
          decoration: BoxDecoration(
            color: appBarColor,
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 30,
              ),
              const Text(
                "Profile Page",
                style: headingStyle,
              ),
              CupertinoButton(
                onPressed: () {
                  showPhotoOption();
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      (imageFile != null) ? FileImage(imageFile!) : null,
                  child: (imageFile != null)
                      ? null
                      : const Icon(
                          Icons.person,
                          size: 70,
                          color: Colors.red,
                        ),
                ),
              ),
              TextField(
                controller: _userNameController,
                decoration: const InputDecoration(
                    hintText: "User Name", hintStyle: textFieldDecorationStyle),
              ),
              const SizedBox(
                height: 30,
              ),
              CupertinoButton(
                onPressed: () {
                  checkValues();
                },
                color: backgroundColor,
                child: const Text(
                  "Submit",
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
    );
  }
}
