import 'package:flutter/material.dart';
import '../../services/app_designs.dart';
import 'camerapage.dart';

class TreeTaggingPage extends StatelessWidget {
  const TreeTaggingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tag a Tree',
          style: AppDesigns
              .titleTextStyle, // Use the title text style from AppDesigns
        ),
        backgroundColor:
            AppDesigns.primaryColor, // Use your primary color from AppDesigns
        elevation: 4, // Adjust elevation for a subtle shadow
        centerTitle: true, // Center the title
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Container(
              padding:
                  const EdgeInsets.all(16.0), // Add padding around the text
              margin: const EdgeInsets.symmetric(
                  vertical: 10.0, horizontal: 16), // Add vertical margin
              decoration: BoxDecoration(
                color: AppDesigns.backgroundColor, // Set a background color
                borderRadius: BorderRadius.circular(10), // Rounded corners
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26, // Shadow color
                    blurRadius: 4.0, // Shadow blur
                    offset: Offset(0, 2), // Shadow position
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align children to the start
                children: [
                  Center(
                    // Center the image
                    child: Image.asset(
                      'assets/book.png', 
                      height: 100, 
                      width: 100, 
                    ),
                  ),
                  const SizedBox(
                      height: 40), 
                  const Text(
                    '1. Take a photo of the tree you want to tag\n'
                    '2. Get close for accurate location accuracy.\n'
                    '3. Classify the tree you want to tag "Optional".',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppDesigns.customButton(
              title: 'Continue',
              onPressed: () {
                // Navigate to the ImagePickerPage when the "Continue" button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ImagePickerPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
