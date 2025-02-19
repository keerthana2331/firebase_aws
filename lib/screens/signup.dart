// ignore_for_file: must_be_immutable, deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:authenticationapp/screens/loginpage.dart';
import 'package:authenticationapp/providers/signup_provider.dart';

class SignUp extends StatelessWidget {
  SignUp({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpState(),
      child: Consumer<SignUpState>(
        builder: (context, signUpState, _) => Scaffold(
          body: Stack(
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
                          horizontal: 30.0, vertical: 85.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildHeader(),
                          const SizedBox(height: 40),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                buildInputField(
                                  controller: nameController,
                                  hintText: "Name",
                                  icon: Icons.person_rounded,
                                  errorText: signUpState.nameError,
                                  onChanged: signUpState.validateName,
                                ),
                                const SizedBox(height: 20),
                                buildInputField(
                                  controller: emailController,
                                  hintText: "Email",
                                  icon: Icons.email_rounded,
                                  errorText: signUpState.emailError,
                                  onChanged: signUpState.validateEmail,
                                ),
                                const SizedBox(height: 20),
                                buildPasswordField(
                                  controller: passwordController,
                                  hintText: "Password",
                                  icon: Icons.lock_rounded,
                                  errorText: signUpState.passwordError,
                                  onChanged: signUpState.validatePassword,
                                ),
                                const SizedBox(height: 40),
                                buildSignUpButton(context, signUpState),
                                const SizedBox(height: 30),
                                buildGoogleSignUp(context, signUpState),
                                const SizedBox(height: 30),
                                buildLoginLink(context),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (signUpState.isLoading)
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

  Widget buildHeader() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Center(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: const AssetImage('assets/avatar.png.png'),
                  ),
                ),
                const SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.orange.shade700,
                      Colors.deepOrange.shade900,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    "Create Account",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    String? errorText,
    required Function(String) onChanged,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1200),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
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
              child: TextFormField(
                controller: controller,
                obscureText: obscureText,
                onChanged: onChanged,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    icon,
                    color: Colors.deepOrange.shade400,
                  ),
                  hintText: hintText,
                  errorText: errorText,
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade400,
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? errorText,
    required Function(String) onChanged,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1200),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
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
              child: TextFormField(
                controller: controller,
                obscureText: !isPasswordVisible,
                onChanged: onChanged,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    icon,
                    color: Colors.deepOrange.shade400,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.deepOrange.shade400,
                    ),
                    onPressed: () {
                      isPasswordVisible = !isPasswordVisible;
                    },
                  ),
                  hintText: hintText,
                  errorText: errorText,
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade400,
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildSignUpButton(BuildContext context, SignUpState signUpState) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1800),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
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
              onPressed: signUpState.isLoading
                  ? null
                  : () => signUpState.signUpUser(
                        nameController.text,
                        emailController.text,
                        passwordController.text,
                        context,
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                "Sign Up",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildGoogleSignUp(BuildContext context, SignUpState signUpState) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 2000),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Column(
            children: [
              Text(
                "Or sign up with",
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: signUpState.isLoading
                    ? null
                    : () => signUpState.signUpWithGoogle(context),
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
          ),
        );
      },
    );
  }

  Widget buildLoginLink(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 2200),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LogIn(),
                  ),
                );
              },
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  children: [
                    const TextSpan(text: "Already have an account? "),
                    TextSpan(
                      text: "Login",
                      style: TextStyle(
                        color: Colors.deepOrange.shade400,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}