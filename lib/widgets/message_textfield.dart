import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageTextfield extends StatefulWidget {
  final String currentId;
  final String friendId;

  MessageTextfield(
      {super.key, required this.currentId, required this.friendId});

  @override
  State<MessageTextfield> createState() => _MessageTextfieldState();
}

class _MessageTextfieldState extends State<MessageTextfield> {
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            controller: _controller,
            decoration: InputDecoration(
                labelText: "Type your message",
                fillColor: Colors.grey,
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 0,
                  ),
                  gapPadding: 10,
                  borderRadius: BorderRadius.circular(25),
                )),
          )),
          const SizedBox(
            width: 20,
          ),
          GestureDetector(
            onTap: () async {
              // First i will store the message inside the variable
              String message = _controller.text;
              // Then i will clear the controller after storing the message inside the variable
              _controller.clear();

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.currentId)
                  .collection('messages')
                  .doc(widget.friendId)
                  .collection('chats')
                  .add({
                // We are sotring(sender and receiver ) ids because if it is sender we will store his message to the write and is it the receiver we will show his message to the left
                'senderId': widget.currentId,
                'receiverId': widget.friendId,
                'message': message,
                'type': 'text',
                'date': DateTime.now(),
              }).then((value) {
                // we will store the last message to show to the home page

                FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.currentId)
                    .collection('messages')
                    .doc(widget.friendId)
                    .set({'last_msg': message});
              });

              // We will do the same thing to the receiver

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.friendId)
                  .collection('messages')
                  .doc(widget.currentId)
                  .collection('chats')
                  .add({
                'senderId': widget.currentId,
                'receiverId': widget.friendId,
                'message': message,
                'type': 'text',
                'date': DateTime.now(),
              }).then((value) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.friendId)
                    .collection('messages')
                    .doc(widget.currentId)
                    .set({
                  'last_msg': message,
                });
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
              child: Icon(Icons.send, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
