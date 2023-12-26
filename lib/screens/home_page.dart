import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dev_chat_app/models/user_model.dart';
import 'package:dev_chat_app/screens/search_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final db = FirebaseFirestore.instance;

  void chatList() {
    db.collection('chatrooms').get().then((querySnapshot) {
      print('successfull fetch');
      for (var docSnapshot in querySnapshot.docs) {
        print("${docSnapshot.data()}");

        // print("${docSnapshot.id}=> ${docSnapshot.data()}");
      }
    }, onError: (e) => print("error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Chat App"),
      ),
      body: const Center(
        child: Text("Home Page"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          chatList();
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => SearchPage(
          //           userModel: widget.userModel,
          //           firebaseUser: widget.firebaseUser),
          //     ));
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
