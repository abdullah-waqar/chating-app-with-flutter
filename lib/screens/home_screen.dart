import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_application/Models/user_model.dart';
import 'package:flutter_chat_application/screens/auth_screen.dart';
import 'package:flutter_chat_application/screens/chat_screen.dart';
import 'package:flutter_chat_application/screens/search_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  UserModel user;

  HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
          centerTitle: true,
          backgroundColor: Colors.teal,
          actions: [
            IconButton(
                onPressed: () async {
                  await GoogleSignIn().signOut();
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => AuthScreen()),
                      (route) => false);
                },
                icon: const Icon(Icons.logout))
          ],
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.user.uid)
                .collection('messages')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.docs.length < 1) {
                  return Center(
                    child: Text("No Chats Avaible !"),
                  );
                }

                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var friendId = snapshot.data!.docs[index].id;
                      var lastMsg = snapshot.data!.docs[index]['last_msg'];

                      return FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(friendId)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var friend = snapshot.data;

                            return ListTile(
                              leading: CircleAvatar(
                                child: Image.network(friend!['image']),
                              ),
                              title: Text(friend['name']),
                              subtitle: Container(
                                child: Text(
                                  '$lastMsg',
                                  style: const TextStyle(color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                            currentUser: widget.user,
                                            friendId: friend['uid'],
                                            friendName: friend['name'],
                                            friendImage: friend['image'])));
                              },
                            );
                          }
                          return LinearProgressIndicator();
                        },
                      );
                    });
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.search),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SearchScreen(user: widget.user)));
          },
        ));
  }
}
