// custom_page_route.dart
import 'package:flutter/material.dart';

class CustomPageRoute extends PageRouteBuilder {
  final Widget child;

  CustomPageRoute({required this.child})
      : super(
          transitionDuration: const Duration(milliseconds: 1000),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            animation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );

            return Stack(
              children: [
                FadeTransition(
                  opacity: Tween<double>(begin: 1, end: 0).animate(animation),
                  child: Container(
                    color: Colors.orange.shade100,
                  ),
                ),
                ScaleTransition(
                  scale: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                ),
              ],
            );
          },
        );
}