// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, library_prefixes

import 'package:authenticationapp/screens/homepage.dart' as authApp;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:email_validator/email_validator.dart';

class LoginState with ChangeNotifier {
  bool isLoading = false;
  String? emailError;
  String? passwordError;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isPasswordVisible = false;

  bool get isPasswordVisible => _isPasswordVisible;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setEmailError(String? error) {
    emailError = error;
    notifyListeners();
  }

  void setPasswordError(String? error) {
    passwordError = error;
    notifyListeners();
  }

  bool validateEmail(String email) {
    if (email.isEmpty) {
      setEmailError('Email is required');
      return false;
    }
    if (!EmailValidator.validate(email)) {
      setEmailError('Please enter a valid email');
      return false;
    }
    setEmailError(null);
    return true;
  }

  bool validatePassword(String password) {
    if (password.isEmpty) {
      setPasswordError('Password is required');
      return false;
    }
    if (password.length < 6) {
      setPasswordError('Password must be at least 6 characters');
      return false;
    }
    setPasswordError(null);
    return true;
  }

  Future<void> logoutCurrentUser() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();
  }

  Future<void> userLogin(
      BuildContext context, String email, String password) async {
    if (!validateEmail(email) || !validatePassword(password)) {
      return;
    }

    setLoading(true);
    try {
      await logoutCurrentUser();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => authApp.Home()));
    } on FirebaseAuthException catch (e) {
      showErrorSnackBar(context, e.code);
    } finally {
      setLoading(false);
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    setLoading(true);
    try {
      await logoutCurrentUser();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setLoading(false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => authApp.Home()));
    } catch (e) {
      showErrorSnackBar(context, "google-sign-in-failed");
    } finally {
      setLoading(false);
    }
  }

  void showErrorSnackBar(BuildContext context, String code) {
    String message;
    switch (code) {
      case 'user-not-found':
        message = "No account found with this email";
        break;
      case 'wrong-password':
        message = "Incorrect password";
        break;
      case 'invalid-email':
        message = "Invalid email address";
        break;
      case 'user-disabled':
        message = "This account has been disabled";
        break;
      case 'too-many-requests':
        message = "Too many attempts. Please try again later";
        break;
      case 'operation-not-allowed':
        message = "Email/password sign in is not enabled";
        break;
      case 'google-sign-in-failed':
        message = "Google sign in failed. Please try again";
        break;
      default:
        message = "Email or Password that You Provided Is Not Existing";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        backgroundColor: Colors.deepOrange.shade400,
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}