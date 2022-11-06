import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_application/main.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // First i will create the instance of google sign in
  GoogleSignIn googleSignIn = GoogleSignIn();
// We will store all the authentication data in firestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future signInFunction() async {
    // This will pop up the menu
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      return;
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    DocumentSnapshot userExist =
        await firestore.collection('users').doc(userCredential.user!.uid).get();

    if (userExist.exists) {
      debugPrint("User already exsit");
    } else {
      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': userCredential.user!.email,
        'name': userCredential.user!.displayName,
        'image': userCredential.user!.photoURL,
        'uid': userCredential.user!.uid,
        'date': DateTime.now(),
      });
    }

    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => MyApp()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTK1kkljo0yMuOPzYDhUHBBvZCIoJKA3nf7RA&usqp=CAU"))),
              ),
            ),
            Text(
              "Flutter Chat App",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: ElevatedButton(
                onPressed: () async {
                  await signInFunction();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      "https://mpng.subpng.com/20180723/btg/kisspng-google-logo-google-search-google-images-g-suite-google-adwords-5b5695e47fdc94.0743248315324011245237.jpg",
                      height: 36,
                      width: 36,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Sign in with Google",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black),
                  padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
