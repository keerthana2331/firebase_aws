// ignore_for_file: prefer_const_constructors, deprecated_member_use, override_on_non_overriding_member

import 'package:authenticationapp/providers/frontpage_provider';
import 'package:authenticationapp/routes/forgetpasswordcustom.dart'
    as forgetpasswordcustom;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'loginpage.dart';

class ToDoListIntro extends StatelessWidget {
  const ToDoListIntro({super.key});

  @override
  Widget build(BuildContext context)  {
    return ChangeNotifierProvider(
      create: (_) => ToDoListIntroProvider(),
      child: Consumer<ToDoListIntroProvider>(
        builder: (context, provider, _) => Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: provider.getBackgroundGradient(),
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildAnimatedLogo(provider),
                    const SizedBox(height: 40.0),
                    buildAnimatedTitle(provider),
                    const SizedBox(height: 15.0),
                    buildFirebaseLabel(provider),
                    const SizedBox(height: 60.0),
                    buildStartButton(context, provider),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAnimatedLogo(ToDoListIntroProvider provider) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: provider.logoAnimationDuration,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, provider.getLogoTranslation(value)),
          child: Transform.scale(
            scale: value,
            child: buildLogoStack(provider),
          ),
        );
      },
    );
  }

  Widget buildLogoStack(ToDoListIntroProvider provider) {
    return Stack(
      alignment: Alignment.center,
      children: [
        buildRotatedContainer(
          offset: const Offset(-15, -15),
          angle: -0.2,
          color: provider.getLogoBackgroundColor1(),
        ),
        buildRotatedContainer(
          offset: const Offset(15, -10),
          angle: 0.2,
          color: provider.getLogoBackgroundColor2(),
        ),
        buildMainContainer(),
      ],
    );
  }

  Widget buildRotatedContainer({
    required Offset offset,
    required double angle,
    required Color color,
  }) {
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMainContainer() {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var width in [80.0, 60.0, 70.0])
            Container(
              height: 2,
              width: width,
              color: Colors.grey.withOpacity(0.3),
              margin: const EdgeInsets.symmetric(vertical: 4),
            ),
        ],
      ),
    );
  }

  Widget buildAnimatedTitle(ToDoListIntroProvider provider) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: provider.titleAnimationDuration,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: provider.getTitleScale(value),
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: provider.getTitleGradient(),
            ).createShader(bounds),
            child: Text(
              "STICKY NOTES",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 36.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 3.0,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildFirebaseLabel(ToDoListIntroProvider provider) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: provider.firebaseAnimationDuration,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: provider.getFirebaseGradient(),
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  "FIREBASE",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildStartButton(
      BuildContext context, ToDoListIntroProvider provider) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: provider.buttonAnimationDuration,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, provider.getButtonTranslation(value)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: provider.getButtonGradient(),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              icon: const Icon(
                Icons.rocket_launch_rounded,
                color: Colors.white,
                size: 28,
              ),
              label: Text(
                "Let's Begin!",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  forgetpasswordcustom.CustomPageRoute(child: LogIn()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 40.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}