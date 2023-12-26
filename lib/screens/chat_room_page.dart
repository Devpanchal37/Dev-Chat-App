import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dev_chat_app/main.dart';
import 'package:dev_chat_app/models/chat_room_model.dart';
import 'package:dev_chat_app/models/message_model.dart';
import 'package:dev_chat_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      messageController.clear();
      print("msg successful");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          CircleAvatar(
            child: Image.network(widget.targetedUser.profilePicUrl.toString()),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(widget.targetedUser.fullname.toString())
        ],
      )),
      body: Container(
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
                                            ? Colors.green
                                            : Colors.blue.shade500,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Text(
                                      currentMessage.text.toString(),
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20),
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
            Container(
              color: Colors.grey.shade200,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Row(
                children: [
                  Flexible(
                      child: TextField(
                    maxLines: null,
                    controller: messageController,
                    decoration: const InputDecoration(
                        hintText: "Write Message", border: InputBorder.none),
                  )),
                  IconButton(
                      onPressed: () {
                        sendMessage();
                      },
                      icon: const Icon(Icons.send))
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}
