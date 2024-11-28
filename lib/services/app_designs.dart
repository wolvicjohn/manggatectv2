import 'package:flutter/material.dart';

class AppDesigns {
  // Common Colors
  static const Color primaryColor = Color.fromARGB(255, 20, 116, 82);
  static const Color accentColor = Color.fromARGB(255, 20, 116, 82);
  static const Color backgroundColor = Color(0xFFF5F5F5);

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
    fontSize: 16,
    color: Colors.blue,
  );

  static const TextStyle headline6 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
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
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // Disable button when loading
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator(
                    color: primaryColor) // Show loading spinner
                : Text(title, style: buttonTextStyle),
          ),
        ),
      ),
    );
  }

  // Location Text Style
  static TextStyle locationTextStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: Colors.black87, // A slightly softer black
  );
}
