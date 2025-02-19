// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    email = email.trim().toLowerCase();
    setLoading(true);
    setErrorMessage(null);

    try {
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isEmpty) {
        setErrorMessage("This email is not registered");
        setLoading(false);
        return false;
      }

      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent');
      setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage = "";
      switch (e.code) {
        case "invalid-email":
          errorMessage = "Invalid email address";
          break;
        case "user-not-found":
          errorMessage = "No account found with this email";
          break;
        case "too-many-requests":
          errorMessage = "Too many reset attempts. Try later";
          break;
        default:
          errorMessage = "Reset failed: ${e.code}";
      }
      setErrorMessage(errorMessage);
      setLoading(false);
      return false;
    } catch (e) {
      setErrorMessage("Unexpected error");
      setLoading(false);
      return false;
    }
  }
}