import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AppDesigns {
  // Common Colors
  static const Color primaryColor = Color.fromARGB(255, 20, 116, 82);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  // Animated Loading Surge Widget
  static Widget loadingIndicator() {
    return const Center(
      child: SpinKitWaveSpinner(
        color: primaryColor,
        size: 50,
      ),
    );
  }

  // Text Styles
  static TextStyle titleTextStyle = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static TextStyle titleTextStyle2 = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  static TextStyle titleTextStyle3 = const TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: Color.fromARGB(255, 104, 74, 45),
  );

  static TextStyle buttonTextStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle labelTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle valueTextStyle = TextStyle(
    fontSize: 25,
    color: Colors.blue,
  );

  static const TextStyle headline6 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: Color.fromARGB(255, 255, 255, 255),
  );

  static const TextStyle bodyText2 = TextStyle(
    fontSize: 14,
    color: Colors.black,
  );

  // Reusable Button Widget
  static Widget customButton({
    required String title,
    required VoidCallback onPressed,
    bool isLoading = false, // Add this parameter
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        splashColor: primaryColor.withOpacity(0.5), // Add splash effect
        highlightColor: primaryColor.withOpacity(0.3), // Add highlight effect
        child: AnimatedScale(
          duration: const Duration(milliseconds: 100), // Animation duration
          scale: isLoading ? 1.0 : 0.95, // Scale down on press
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: isLoading
                    ? loadingIndicator() // Show loading indicator when loading
                    : Text(title, style: buttonTextStyle),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Custom AlertDialog design
  static Widget customDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onYes,
    required VoidCallback onNo,
  }) {
    return AlertDialog(
      backgroundColor: AppDesigns.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: Text(
        title,
        style: labelTextStyle,
      ),
      content: Text(
        content,
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: onNo,
          child: const Text(
            'No',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ),
        TextButton(
          onPressed: onYes,
          child: const Text(
            'Yes',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ),
      ],
    );
  }

  // Location Text Style
  static TextStyle locationTextStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );

  // Staggered Animation for List Items
  static Widget staggeredAnimation({
    required AnimationController controller,
    required int index,
    required int totalItems,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: controller,
        curve: Interval(
          (index / totalItems) * 0.7, // Spread the animation for items
          1.0,
          curve: Curves.easeOut,
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 0.3 * (index + 1)), // Adjust starting offset
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              (index / totalItems) * 0.7,
              1.0,
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}
