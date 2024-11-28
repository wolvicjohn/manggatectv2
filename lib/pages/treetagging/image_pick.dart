import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/app_designs.dart';
import 'confirm_page.dart'; 

class ClassifyPage extends StatefulWidget {
  final String latitude;
  final String longitude; 
  final File image;

  const ClassifyPage({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.image,
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
      File stageImage = File(pickedFile.path);
      print("Image picked: ${stageImage.path}, Size: ${await stageImage.length()} bytes");

      // Navigate to ConfirmPage with the selected image, latitude, and longitude
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmPage(
            stageImage: stageImage,
            image: widget.image,
            latitude: widget.latitude, 
            longitude: widget.longitude, 
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
