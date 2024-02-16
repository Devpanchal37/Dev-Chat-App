import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dev_chat_app/component/error_show_widget.dart';
import 'package:dev_chat_app/models/chat_room_model.dart';
import 'package:dev_chat_app/models/firebase_helper.dart';
import 'package:dev_chat_app/models/user_model.dart';
import 'package:dev_chat_app/screens/chat_room_page.dart';
import 'package:dev_chat_app/screens/search_page.dart';
import 'package:dev_chat_app/screens/user_login.dart';
import 'package:dev_chat_app/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void uploadData() async {
    String? subscriptionId;
    print("uploading subscriptionId");
    Future.delayed(Duration(seconds: 1), () async {
      String subscriptionId = OneSignal.User.pushSubscription.id.toString();
      print("subscriptionnnnnnn id:    ${OneSignal.User.pushSubscription.id}");
      widget.userModel.subscriptionId = subscriptionId;
      await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.userModel.uid)
          .set(widget.userModel.toMap());
      print("hureeyyy ... subscriptionId uploadedddd");
    });
  }

  void oneSignalInitialization() async {
    await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.initialize("a41c0bac-f06a-4c42-b5dc-858d5890835c");
// The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    await OneSignal.Notifications.requestPermission(true); //
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    oneSignalInitialization();
// Remove this method to stop OneSignal Debugging
//     OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
//
//     OneSignal.initialize("a41c0bac-f06a-4c42-b5dc-858d5890835c");
// // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
//     OneSignal.Notifications.requestPermission(true); //

    uploadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        centerTitle: true,
        title: const Text(
          "Chat App",
          style: titleStyle,
        ),
        actions: [
          IconButton(
              onPressed: () {
                showErrorDialog(
                    context: context,
                    error: "Are you sure want Logout?",
                    signOut: "yes");
                // FirebaseAuth.instance.signOut();
                // OneSignal.Notifications.clearAll();
                // OneSignal.logout();
                // Navigator.popUntil(context, (route) => route.isFirst);
                // Navigator.pushReplacement(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => UserLogin(),
                //     ));
              },
              icon: const Icon(
                Icons.exit_to_app,
                color: fontColor,
                size: 30,
              ))
        ],
      ),
      body: Container(
        color: backgroundColor,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chatrooms')
              .where("participants.${widget.userModel.uid}", isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else if (snapshot.hasData) {
              QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;

              return ListView.builder(
                itemCount: chatRoomSnapshot.docs.length,
                itemBuilder: (context, index) {
                  ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                      chatRoomSnapshot.docs[index].data()
                          as Map<String, dynamic>);
                  Map<String, dynamic>? participants =
                      chatRoomModel.participants;
                  List<String> participantkeys = participants!.keys.toList();
                  participantkeys.remove(widget.userModel.uid);

                  return FutureBuilder(
                    future: FirebaseHelper.fetchUserData(participantkeys[0]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.data != null) {
                          UserModel targetedUser = snapshot.data as UserModel;
                          return Column(
                            children: [
                              ListTile(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return ChatRoomPage(
                                          targetedUser: targetedUser,
                                          chatRoom: chatRoomModel,
                                          userModel: widget.userModel,
                                          fireBaseUser: widget.firebaseUser);
                                    },
                                  ));
                                },
                                leading: ClipOval(
                                  child: Image.network((targetedUser
                                          .profilePicUrl
                                          .toString()
                                          .isNotEmpty)
                                      ? targetedUser.profilePicUrl.toString()
                                      : "https://via.placeholder.com/150/0000FF/808080 ?Text=PAKAINFO.com"),
                                ),
                                title: Text(
                                  (targetedUser.fullname.toString().isNotEmpty)
                                      ? targetedUser.fullname.toString()
                                      : "User",
                                  style: usernameStyle,
                                ),
                                subtitle: Text(
                                  chatRoomModel.lastMessage.toString(),
                                  style: messageStyle,
                                ),
                              ),
                              Divider(
                                color: appBarColor,
                              )
                            ],
                          );
                        } else {
                          return Container();
                        }
                      } else {
                        return Container();
                      }
                    },
                  );
                },
              );
            } else {
              return const Center(
                child: Text("No Chats"),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: appBarColor,
        onPressed: () {
          // chatList();
          print(
              "subscriptionnnnnnn id:    ${OneSignal.User.pushSubscription.id}");
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchPage(
                    userModel: widget.userModel,
                    firebaseUser: widget.firebaseUser),
              ));
        },
        child: const Icon(
          Icons.search,
          color: backgroundColor,
          size: 30,
        ),
      ),
    );
  }
}
