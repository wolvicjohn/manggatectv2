import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/app_designs.dart';
import 'confirmpage.dart';

class ClassifyPage extends StatefulWidget {
  @override
  _ClassifyPageState createState() => _ClassifyPageState();
}

class _ClassifyPageState extends State<ClassifyPage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File image = File(pickedFile.path);
      print("Image picked: ${image.path}, Size: ${await image.length()} bytes");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmPage(image: image),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Classify Image',
          style: AppDesigns.titleTextStyle,
        ),
        backgroundColor: AppDesigns.primaryColor,
        elevation: 4, // Adjust elevation for a subtle shadow
        centerTitle: true, // Center the title
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
            AppDesigns.customButton(
              title: 'Pick from Gallery',
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(height: 20),
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
