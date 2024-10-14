import 'package:flutter/material.dart';

class AppDesigns {
  // Common Colors
  static const Color primaryColor = Color(0xFF4CAF50); // Green
  static const Color accentColor = Color(0xFF81C784); // Light Green
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light Grey

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
    fontSize: 50,
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
    color: Colors.black, // Set color to black
  );

  static const TextStyle bodyText2 = TextStyle(
    fontSize: 14,
    color: Colors.black, // Set color to black
  );

  // Reusable Button Widget
  static Widget customButton({
    required String title,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0), // Adjust horizontal padding
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
        child: SizedBox(
          width: double.infinity, // Make the button stretch to full width
          child: Center(
            child: Text(title, style: buttonTextStyle),
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
