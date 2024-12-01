import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:manggatectv2/pages/treetagging/ResultPage.dart';
import 'package:manggatectv2/utility/custom_page_transition.dart';
import '../../services/app_designs.dart';

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
  bool _isLoading = false; // Track loading state

  // Function to pick an image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File stageImage = File(pickedFile.path);
      print(
          "Image picked: ${stageImage.path}, Size: ${await stageImage.length()} bytes");

      // Navigate to ResultPage with the selected image, latitude, and longitude
      Navigator.push(
        context,
        CustomPageTransition(
          page: ResultPage(
            stageImage: stageImage,
            image: widget.image,
            latitude: widget.latitude,
            longitude: widget.longitude,
          ),
        ),
      );
    }

    setState(() {
      _isLoading = false; // Hide loading indicator once image is processed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classify Image'),
        backgroundColor: AppDesigns.primaryColor, 
      ),
      body: Center(
        child: _isLoading
            ? AppDesigns.loadingIndicator()
            : Column(
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
