import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_application/Models/user_model.dart';
import 'package:flutter_chat_application/widgets/message_textfield.dart';
import 'package:flutter_chat_application/widgets/single_message.dart';

class ChatScreen extends StatelessWidget {
  // First we will need the current user who is messaging
  final UserModel currentUser;

  // Second we will neeed the id of second user whom to be messaged we need his uid

  final String friendId;
  final String friendName;
  final String friendImage;

  ChatScreen(
      {super.key,
      required this.currentUser,
      required this.friendId,
      required this.friendName,
      required this.friendImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(80),
              child: Image.network(
                friendImage,
                height: 35,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              friendName,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25)),
            ),
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid)
                    .collection('messages')
                    .doc(friendId)
                    .collection('chats')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.docs.length < 1) {
                      return Center(
                        child: Text("Say hi"),
                      );
                    }
                    // If it has data more than when(It means user have chats)

                    return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        reverse: true,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          // if the isMe is true then show the message on the right side else show the message on left side

                          bool isMe = snapshot.data!.docs[index]['senderId'] ==
                              currentUser.uid;

                          return SingleMessage(
                              message: snapshot.data!.docs[index]['message'],
                              isMe: isMe);
                        });
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                })),
          )),
          MessageTextfield(currentId: currentUser.uid, friendId: friendId),
        ],
      ),
    );
  }
}
