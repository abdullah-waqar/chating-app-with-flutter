import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_application/Models/user_model.dart';
import 'package:flutter_chat_application/screens/auth_screen.dart';
import 'package:flutter_chat_application/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

// Here we will check user Already signed in or not
// if the user already signed in then we will go to the home page
// other wise we go the auth screen
  Future<Widget> userSignedIn() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // fetching the data from firestore

      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      // Now we will send the fetched data to our own model

      UserModel userModel = UserModel.fromJson(userData);

      // We will send the data to our home screen by navigating
      return HomeScreen(user: userModel,);
    } else {
      return AuthScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chatt App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
          future: userSignedIn(),
          builder: (context, AsyncSnapshot<Widget> snapshot) {
            if (snapshot.hasData) {
              // It means simply return the widget
              return snapshot.data!;
            }
            // Otherwise show the progress indicator

            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }),
    );
  }
}
