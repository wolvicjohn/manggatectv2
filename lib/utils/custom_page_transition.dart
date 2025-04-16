// lib/utils/custom_page_transition.dart
import 'package:flutter/material.dart';

class CustomPageTransition extends PageRouteBuilder {
  final Widget page;

  CustomPageTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Slide transition from right to left
            const offsetBegin = Offset(1.0, 0.0); // Slide in from the right
            const offsetEnd = Offset.zero;
            var tween = Tween(begin: offsetBegin, end: offsetEnd);
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
        );
}

class BottomSlidePageTransition extends PageRouteBuilder {
  final Widget page;

  BottomSlidePageTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Slide transition from bottom to top
            const offsetBegin = Offset(0.0, 1.0); // Slide in from the bottom
            const offsetEnd = Offset.zero;
            var tween = Tween(begin: offsetBegin, end: offsetEnd);
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
        );
}


class PopTransition extends PageRouteBuilder {
  final Widget page;

  PopTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0); // Start from bottom
            const end = Offset.zero; // End at original position
            const curve = Curves.easeOut; // Ease-out animation curve

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}