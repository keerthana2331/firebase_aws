// verification_state.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:authenticationapp/screens/homepage.dart';

class VerificationState extends ChangeNotifier {
  final User user;
  Timer? timer;
  bool isLoading = false;
  final BuildContext context;

  VerificationState(this.user, this.context) {
    startVerificationCheck();
  }

  void startVerificationCheck() {
    timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await checkEmailVerification();
    });
  }

  Future<void> checkEmailVerification() async {
    await user.reload();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null && currentUser.emailVerified) {
      timer?.cancel();
      
      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'emailVerified': true});

      // Navigate to Home Screen
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false,
        );
      }

      notifyListeners();
    }
  }

  Future<void> resendVerificationEmail() async {
    isLoading = true;
    notifyListeners();

    try {
      await user.sendEmailVerification();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}