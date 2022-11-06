import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_application/Models/user_model.dart';
import 'package:flutter_chat_application/screens/chat_screen.dart';

class SearchScreen extends StatefulWidget {
  UserModel user;

  SearchScreen({super.key, required this.user});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();

  // When we fetch the data from firestore it will be in the json format
  // so i have to convert it into the map of list

  List<Map> searchResult = [];

  bool isLoading = false;

  void onSearch() async {
    setState(() {
      // When we click on the search result button i want it to be empty
      searchResult = [];
      isLoading = true;
    });

    await FirebaseFirestore.instance
        .collection('users')
        .where("name", isEqualTo: searchController.text)
        .get()
        .then((value) {
      // If we dont have users
      if (value.docs.length < 1) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("No user Found")));
        setState(() {
          isLoading = false;
        });
        // At the end we will come out of the function
        return;
      }

      // If we have users

      value.docs.forEach((user) {
        // I dont want to show the user itself on the search list
        if (user.data()['email'] != widget.user.email) {
          searchResult.add(user.data());
        }
        setState(() {
          isLoading = false;
        });
      });
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Something gone wrong")));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search your friend"),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                        hintText: "Type username...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        )),
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    onSearch();
                  },
                  icon: const Icon(Icons.search)),
            ],
          ),

          // IF some data is there in searchResult

          if (searchResult.length > 0)
            Expanded(
                child: ListView.builder(
                    itemCount: searchResult.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Image.network(searchResult[index]['image']),
                        ),
                        title: Text(searchResult[index]['name']),
                        subtitle: Text(searchResult[index]['email']),
                        trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                searchController.text = "";
                              });
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                          currentUser: widget.user,
                                          friendId: searchResult[index]['uid'],
                                          friendName: searchResult[index]
                                              ['name'],
                                          friendImage: searchResult[index]
                                              ['image'])));
                            },
                            icon: const Icon(Icons.message)),
                      );
                    }))
          else if (isLoading = true)
            Center(
              child: CircularProgressIndicator(),
            )
        ],
      ),
    );
  }
}
