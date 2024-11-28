import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/app_designs.dart';
import 'displayoutputpage.dart';
import 'treelocation.dart';

class ImagePickerPage extends StatefulWidget {
  const ImagePickerPage({super.key});

  @override
  State<ImagePickerPage> createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  final ImagePicker _picker = ImagePicker(); // Initialize image picker
  late File _selectedImage; // Store the selected image

  // Function to capture an image using the camera
  Future<void> _captureImageWithCamera() async {
    try {
      final XFile? capturedFile =
          await _picker.pickImage(source: ImageSource.camera);

      if (capturedFile != null) {
        setState(() {
          _selectedImage = File(capturedFile.path);
        });

        // Navigate to TreeLocationPage to get location
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TreeLocationPage(image: _selectedImage),
          ),
        );
      } else {
        // Handle case when the user cancels image capture
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image capture canceled.')),
        );
      }
    } catch (e) {
      // Handle any errors during image picking
      print('Error capturing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Capture Tree',
          style: AppDesigns.titleTextStyle,
        ),
        backgroundColor: AppDesigns.primaryColor,
        elevation: 4,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/camera.png', // Replace with your asset image path
              height: 300,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            AppDesigns.customButton(
              title: 'Capture',
              onPressed: _captureImageWithCamera,
            ),
          ],
        ),
      ),
    );
  }
}
