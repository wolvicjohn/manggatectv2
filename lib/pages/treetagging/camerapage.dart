import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manggatectv2/utility/custom_page_transition.dart';
import 'dart:io';
import '../../services/app_designs.dart';
import 'treelocation.dart';

class ImagePickerPage extends StatefulWidget {
  final String username;
  ImagePickerPage({super.key, required this.username});

  @override
  State<ImagePickerPage> createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  final ImagePicker _picker = ImagePicker(); // Initialize image picker
  late File _selectedImage; // Store the selected image

  @override
  void initState() {
    super.initState();
    _captureImageWithCamera(); // Automatically trigger the camera
  }

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
        Navigator.pushReplacement(
          context,
          CustomPageTransition(
              page: TreeLocationPage(
            image: _selectedImage,
            username: widget.username,
          )),
        );
      } else {
        // Handle case when the user cancels image capture
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image capture canceled.')),
        );
        Navigator.pop(context);
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
      body: Center(
        child: AppDesigns
            .loadingIndicator(), // Show a loading indicator while the camera is being triggered
      ),
    );
  }
}
