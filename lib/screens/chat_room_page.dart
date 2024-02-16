import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dev_chat_app/main.dart';
import 'package:dev_chat_app/models/chat_room_model.dart';
import 'package:dev_chat_app/models/message_model.dart';
import 'package:dev_chat_app/models/user_model.dart';
import 'package:dev_chat_app/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetedUser;
  final ChatRoomModel chatRoom;
  final UserModel userModel;
  final User fireBaseUser;

  const ChatRoomPage(
      {super.key,
      required this.targetedUser,
      required this.chatRoom,
      required this.userModel,
      required this.fireBaseUser});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  Future<Response> sendNotification(
      {required String contents, required String heading}) async {
    print("starting one signal notification");
    print(
        "targeted user subscription idddddddddd: ${widget.targetedUser.subscriptionId}");
    return await post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        // 'Authorization':
        //     'Bearer OTY4NDcwOTMtMzU1Mi00NzkwLTk3NjktMzZhMjBjYzUwMTc2'
      },
      body: jsonEncode(<String, dynamic>{
        "app_id": "a41c0bac-f06a-4c42-b5dc-858d5890835c",
        //kAppId is the App Id that one get from the OneSignal When the application is registered.

        "include_player_ids": [widget.targetedUser.subscriptionId],
        //tokenIdList Is the List of All the Token Id to to Whom notification must be sent.

        // android_accent_color reprsent the color of the heading text in the notifiction
        "android_accent_color": "FF9976D2",

        "small_icon": "ic_stat_onesignal_default",

        "large_icon":
            "https://www.filepicker.io/api/file/zPloHSmnQsix82nlj9Aj?filename=name.jpg",

        "headings": {"en": heading},

        "contents": {"en": contents},
      }),
    );
  }

  void sendMessage() async {
    String message = messageController.text.trim();
    if (message.isNotEmpty) {
      MessageModel newMessage = MessageModel(
          sender: widget.userModel.uid,
          text: message,
          messageId: uuid.v1(),
          createdon: DateTime.now(),
          seen: false);

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoom.chatRoomId)
          .collection("messages")
          .doc(newMessage.messageId)
          .set(newMessage.toMap());
      widget.chatRoom.lastMessage = message;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoom.chatRoomId)
          .set(widget.chatRoom.toMap());

      // void sendOneSignalNotification(String message) async {
      //   var status = OneSignal.User.pushSubscription.id;
      //   OneSignal.User.addTagWithKey("test2", "val1");
      //   print("idddddddddddddddddddddddddddddddd:          : ${status}");
      //   var notification = OSNotification({
      //     'playerIds': '$status',
      //     // 'smallIcon': 'ic_stat_one_signal_default',
      //     // 'largeIcon': 'ic_stat_one_signal_default',
      //     // 'title': 'title',
      //     // 'sound': 'sound',
      //     // 'body': 'message',
      //     // 'buttons': '[OSActionButton(text: "OK", id: "id1")]',
      //   });
      //   print("NOTIFICATIONNNNNNNNNNNNNNNNNN:         ${notification}");
      //   // await OneSignal.Notifications.
      // }
      sendNotification(contents: message, heading: widget.userModel.fullname!)
          .then((value) => print("${value.body}"));
      messageController.clear();
      print("msg successful");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: appBarColor,
          title: Row(
            children: [
              CircleAvatar(
                child: Image.network(
                  widget.targetedUser.profilePicUrl.toString(),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  (widget.targetedUser.fullname.toString().isNotEmpty)
                      ? widget.targetedUser.fullname.toString()
                      : " User",
                  style: titleStyle,
                ),
              )
            ],
          )),
      body: Container(
        color: backgroundColor,
        child: Column(
          children: [
            // chat area
            Expanded(
                child: Container(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatrooms")
                    .doc(widget.chatRoom.chatRoomId)
                    .collection("messages")
                    .orderBy("createdon", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;
                      return Align(
                        alignment: Alignment.centerRight,
                        child: ListView.builder(
                          reverse: true,
                          // shrinkWrap: true,
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            MessageModel currentMessage = MessageModel.fromMap(
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>);
                            String? currentMsgSender = currentMessage.sender;
                            String? logedUser = widget.userModel.uid;
                            return Row(
                              mainAxisAlignment: (currentMsgSender == logedUser)
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 3, horizontal: 10),
                                    decoration: BoxDecoration(
                                        color: (currentMsgSender == logedUser)
                                            ? Color.fromRGBO(234, 219, 200, 1)
                                            : Color.fromRGBO(218, 192, 163, 1),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Text(
                                      currentMessage.text.toString(),
                                      style: messageStyle,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text("Please check internet connection"),
                      );
                    } else {
                      return const Center(
                        child: Text("Say hi to your new Friend"),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            )),
            Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
                  color: appBarColor,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Row(
                    children: [
                      Flexible(
                          child: TextField(
                        maxLines: null,
                        controller: messageController,
                        decoration: const InputDecoration(
                            hintText: "Write Message",
                            hintStyle: TextStyle(color: fontColor),
                            border: InputBorder.none),
                      )),
                      IconButton(
                          onPressed: () {
                            sendMessage();
                          },
                          icon: const Icon(
                            Icons.send,
                            size: 30,
                            color: backgroundColor,
                          ))
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
