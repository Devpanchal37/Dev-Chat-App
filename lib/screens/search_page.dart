import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dev_chat_app/main.dart';
import 'package:dev_chat_app/models/user_model.dart';
import 'package:dev_chat_app/screens/chat_room_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/chat_room_model.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _emailController = TextEditingController();

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    //BCZ IT'S RETURN CHATROOMMODEL SO WE DEFINE A VAR
    ChatRoomModel chatRoom;
    // Checking that chatroom already exit between two user or not
    // go in chatroom and search for participants
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();
    if (snapshot.docs.isNotEmpty) {
      //FETCH THE EXISTING CHATROOM
      var docData = snapshot.docs[0].data();

      ChatRoomModel existingChatRoom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = existingChatRoom;
      print("exist");
    } else {
      //CREATE NEW CHATROOM
      ChatRoomModel newChatRoom = ChatRoomModel(
          chatRoomId: uuid.v1(),
          lastMessage: "",
          participants: {
            widget.userModel.uid.toString(): true,
            targetUser.uid.toString(): true
          });
      //ADD IN FIREBASE
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatRoom.chatRoomId)
          .set(newChatRoom.toMap());

      chatRoom = newChatRoom;
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Chat App"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(hintText: "Enter Email"),
            ),
            const SizedBox(
              height: 50,
            ),
            CupertinoButton(
              color: Colors.purple.shade500,
              onPressed: () {
                setState(() {});
                // searchUser(_emailController.text.trim());
              },
              child: const Text("Search"),
            ),
            StreamBuilder(
              //check email equal or not
              stream: FirebaseFirestore.instance
                  .collection("user")
                  .where("email", isEqualTo: _emailController.text)
                  .where("email", isNotEqualTo: widget.firebaseUser.email)
                  .snapshots(),
              builder: (context, snapshot) {
                //check snapshot state
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    //convert snapshot data in query snapshot
                    QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                    if (dataSnapshot.docs.isNotEmpty) {
                      // we want map from querysnapshot
                      Map<String, dynamic> userMap =
                          dataSnapshot.docs[0].data() as Map<String, dynamic>;
                      UserModel searchedUser = UserModel.fromMap(userMap);
                      return ListTile(
                        onTap: () async {
                          print("hellloooooo");
                          ChatRoomModel? chatRoomModel =
                              await getChatRoomModel(searchedUser);
                          print("yeah");
                          if (chatRoomModel != null) {
                            print("he");
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatRoomPage(
                                    targetedUser: searchedUser,
                                    chatRoom: chatRoomModel,
                                    userModel: widget.userModel,
                                    fireBaseUser: widget.firebaseUser,
                                  ),
                                ));
                          }
                        },
                        contentPadding: const EdgeInsets.only(left: 0),
                        leading: ClipOval(
                          child: Image.network(searchedUser.profilePicUrl!),
                        ),
                        trailing: const Icon(CupertinoIcons.right_chevron),
                        title: Text(searchedUser.fullname.toString()),
                        subtitle: Text(searchedUser.email.toString()),
                      );
                    } else {
                      return const Text("No data found");
                    }
                    // datasnapshot have array of doc
                  } else if (snapshot.hasError) {
                    return Text("error occured");
                  } else {
                    return const Text("No data found");
                  }
                } else {
                  return const CircularProgressIndicator();
                }
              },
            )
            // Container(
            //     height: 500,
            //     color: (_userSnapshot.isEmpty) ? Colors.red : Colors.blue,
            //     child: (_userSnapshot.isNotEmpty)
            //         ? ListView.builder(
            //             shrinkWrap: true,
            //             itemCount: _userSnapshot.length,
            //             itemBuilder: (context, index) {
            //               Map<String, dynamic> userData =
            //                   _userSnapshot[index].data()!;
            //               return Column(
            //                 children: [
            //                   ListTile(
            //                     title: Text('Name: ${userData['fullname']}'),
            //                     subtitle: Text('Name: ${userData['email']}'),
            //                   ),
            //                   ListTile(
            //                     title: Text('Name: ${userData['fullname']}'),
            //                   ),
            //                   Image.network((userData['profilePicUrl'] == "")
            //                       ? "https://picsum.photos/200"
            //                       : userData['profilePicUrl']),
            //                   Text(userData['uid']),
            //                 ],
            //               );
            //             },
            //           )
            //         : const Center(child: Text("no data")))
          ],
        ),
      ),
    );
  }
}
