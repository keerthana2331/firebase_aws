// ignore_for_file: unreachable_switch_default, await_only_futures, prefer_const_constructors, use_build_context_synchronously, non_constant_identifier_names, use_rethrow_when_possible;
import 'package:authenticationapp/models/database.dart';
import 'package:authenticationapp/screens/homepage.dart' as app;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return await auth.currentUser;
  }

  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    final GoogleSignInAuthentication? googleSignInAuthentication =
        await googleSignInAccount?.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication?.idToken,
        accessToken: googleSignInAuthentication?.accessToken);

    UserCredential result = await firebaseAuth.signInWithCredential(credential);

    User? userDetails = result.user;

    // ignore: unnecessary_null_comparison
    if (result != null) {
      Map<String, dynamic> userInfoMap = {
        "email": userDetails!.email,
        "name": userDetails.displayName,
        "imgUrl": userDetails.photoURL,
        "id": userDetails.uid
      };
      await DatabaseMethods()
          .addUser(userDetails.uid, userInfoMap)
          .then((value) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => app.Home()));
      });
    }
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    }
  }
}