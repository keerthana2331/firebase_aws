// ignore_for_file: no_leading_underscores_for_local_identifiers, deprecated_member_use, prefer_const_constructors

import 'package:authenticationapp/providers/login_provider.dart';
import 'package:authenticationapp/routes/frontpagecustom.dart' as front_page;

import 'package:authenticationapp/screens/signup.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'frontpage.dart' as front_page;
import 'forgetpassword.dart' as forget_password;

class LogIn extends StatelessWidget {
  const LogIn({super.key});

  @override
  Widget build(BuildContext context) {
    final mailController = TextEditingController();
    final passwordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    return ChangeNotifierProvider(
      create: (_) => LoginState(),
      child: Scaffold(
        body: Consumer<LoginState>(
          builder: (context, loginState, _) => Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.yellow.shade100,
                      Colors.orange.shade100,
                      Colors.deepOrange.shade100,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50.0, vertical: 122.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        buildBackButton(context),
                        const SizedBox(height: 20),
                        Center(child: buildWelcomeText()),
                        const SizedBox(height: 30),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              buildEmailField(mailController, loginState),
                              const SizedBox(height: 15),
                              buildPasswordField(
                                  passwordController, loginState),
                              const SizedBox(height: 25),
                              buildLoginButton(context, loginState,
                                  mailController, passwordController),
                              const SizedBox(height: 20),
                              buildForgotPasswordButton(context),
                              const SizedBox(height: 30),
                              buildGoogleSignIn(context, loginState),
                              const SizedBox(height: 25),
                              buildSignUpSection(context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ),
              ),
              if (loginState.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBackButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_rounded,
        color: Colors.deepOrange.shade400,
      ),
      onPressed: () => Navigator.pushReplacement(
        context,
        front_page.CustomPageRoute(child: front_page.ToDoListIntro()),
      ),
    );
  }

  Widget buildWelcomeText() {
    return Text(
      "Welcome Back!",
      style: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.deepOrange.shade400,
      ),
    );
  }

  Widget buildEmailField(
      TextEditingController mailController, LoginState loginState) {
    return TextFormField(
      controller: mailController,
      style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        prefixIcon:
            Icon(Icons.email_rounded, color: Colors.deepOrange.shade400),
        hintText: "Email",
        errorText: loginState.emailError,
        hintStyle:
            GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 16),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
      ),
      onChanged: (value) => loginState.validateEmail(value),
    );
  }

  Widget buildPasswordField(
      TextEditingController passwordController, LoginState loginState) {
    return TextFormField(
      controller: passwordController,
      obscureText: !loginState.isPasswordVisible,
      style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock_rounded, color: Colors.deepOrange.shade400),
        hintText: "Password",
        errorText: loginState.passwordError,
        hintStyle:
            GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 16),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            loginState.isPasswordVisible
                ? Icons.visibility
                : Icons.visibility_off,
            color: Colors.deepOrange.shade400,
          ),
          onPressed: () => loginState.togglePasswordVisibility(),
        ),
      ),
      onChanged: (value) => loginState.validatePassword(value),
    );
  }

  Widget buildLoginButton(
      BuildContext context,
      LoginState loginState,
      TextEditingController mailController,
      TextEditingController passwordController) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade400,
            Colors.deepOrange.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: loginState.isLoading
            ? null
            : () => loginState.userLogin(
                  context,
                  mailController.text,
                  passwordController.text,
                ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          "Login",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildForgotPasswordButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.push(
        context,
        front_page.CustomPageRoute(child: forget_password.ForgotPassword()),
      ),
      child: Text(
        "Forgot Password?",
        style: GoogleFonts.poppins(
          color: Colors.deepOrange.shade400,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget buildGoogleSignIn(BuildContext context, LoginState loginState) {
    return Column(
      children: [
        Text(
          "Or continue with",
          style: GoogleFonts.poppins(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: loginState.isLoading
              ? null
              : () => loginState.signInWithGoogle(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Image.asset(
              "assets/google.png.png",
              height: 30,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSignUpSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: GoogleFonts.poppins(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            front_page.CustomPageRoute(child: SignUp()),
          ),
          child: Text(
            "Sign Up",
            style: GoogleFonts.poppins(
              color: Colors.deepOrange.shade400,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}