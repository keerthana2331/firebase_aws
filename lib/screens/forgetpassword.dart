// ignore_for_file: prefer_const_constructors, deprecated_member_use, use_build_context_synchronously

import 'package:authenticationapp/providers/forgetpassword_provider.dart';
import 'package:authenticationapp/routes/forgetpasswordcustom.dart'
    as custom_route;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'loginpage.dart';
import 'signup.dart';

class ForgotPassword extends StatelessWidget {
  ForgotPassword({super.key});

  final TextEditingController mailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordProvider(),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
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
              child: Consumer<ForgotPasswordProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepOrange,
                      ),
                    );
                  }

                  if (provider.errorMessage != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(10),
                          backgroundColor: Colors.deepOrange.shade400,
                          duration: const Duration(seconds: 4),
                          content: Text(
                            provider.errorMessage!,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      );
                    });
                  }

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          buildBackButton(context),
                          const SizedBox(height: 20),
                          buildHeader(),
                          const SizedBox(height: 40),
                          buildForm(context, provider),
                          const SizedBox(height: 40),
                          buildSignUpLink(context),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBackButton(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.deepOrange.shade400,
            ),
            onPressed: () => Navigator.pushReplacement(
              context,
              custom_route.CustomPageRoute(child: LogIn()),
            ),
          ),
        );
      },
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
                    child: Icon(
                      Icons.lock_reset_rounded,
                      size: 50,
                      color: Colors.deepOrange.shade400,
                    ),
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
                    "Reset Password",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Enter your registered email to receive\na password reset link.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildForm(BuildContext context, ForgotPasswordProvider provider) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmailField(),
          const SizedBox(height: 40),
          buildSubmitButton(context, provider),
        ],
      ),
    );
  }

  Widget buildEmailField() {
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
                controller: mailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.email_rounded,
                    color: Colors.deepOrange.shade400,
                  ),
                  hintText: "Email",
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

  Widget buildSubmitButton(
      BuildContext context, ForgotPasswordProvider provider) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1400),
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
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  bool success =
                      await provider.resetPassword(mailController.text);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(10),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 4),
                        content: Text(
                          "Password reset link sent! Please check your email.",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    );
                    Navigator.pushReplacement(
                      context,
                      custom_route.CustomPageRoute(child: const LogIn()),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                "Send Reset Link",
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

  Widget buildSignUpLink(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1600),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Row(
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
                onTap: () => Navigator.pushReplacement(
                  context,
                  custom_route.CustomPageRoute(child: SignUp()),
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
          ),
        );
      },
    );
  }
}