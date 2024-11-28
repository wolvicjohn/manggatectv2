import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manggatectv2/pages/qrscanning/classifyqrpage.dart';
import '../../services/app_designs.dart';

class ImagePickPage extends StatefulWidget {
  final String docID;
  const ImagePickPage({
    required this.docID,
    super.key,
  });

  @override
  _ImagePickPageState createState() => _ImagePickPageState();
}

class _ImagePickPageState extends State<ImagePickPage> {
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File stageImage = File(pickedFile.path);
      print(
          "Image picked: ${stageImage.path}, Size: ${await stageImage.length()} bytes");

      // Navigate to ConfirmPage with the selected image, latitude, and longitude
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmPage(
            docID: widget.docID,
            stageImage: stageImage,
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
