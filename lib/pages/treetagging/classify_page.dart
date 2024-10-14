import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/app_designs.dart'; // Ensure you have this file for design consistency
import 'confirm_page.dart'; // Import the ConfirmPage

class ClassifyPage extends StatefulWidget {
  final String latitude; // Add latitude parameter
  final String longitude; // Add longitude parameter

  const ClassifyPage({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  _ClassifyPageState createState() => _ClassifyPageState();
}

class _ClassifyPageState extends State<ClassifyPage> {
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File image = File(pickedFile.path);
      print("Image picked: ${image.path}, Size: ${await image.length()} bytes");

      // Navigate to ConfirmPage with the selected image, latitude, and longitude
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmPage(
            image: image,
            latitude: widget.latitude, // Pass latitude
            longitude: widget.longitude, // Pass longitude
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classify Image'),
        backgroundColor: AppDesigns.primaryColor, // Use the same primary color
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Button to pick image from the gallery
            AppDesigns.customButton(
              title: 'Pick from Gallery',
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(height: 20),
            // Button to capture image from the camera
            AppDesigns.customButton(
              title: 'Capture from Camera',
              onPressed: () => _pickImage(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }
}
