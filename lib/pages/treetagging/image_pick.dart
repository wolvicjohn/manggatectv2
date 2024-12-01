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
  bool _isLoading = false;

  // Function to pick an image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    // Simulate a delay with loading indicator
    await Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false; // Hide loading indicator after delay
      });
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
      _isLoading = false; // Hide loading indicator after image is picked
    });
  }

  // Function to show modal with image pick options
  void _showImagePickerModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick an Image'),
          content: _isLoading
              ? AppDesigns.loadingIndicator() // Show loading indicator
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the modal
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Image'),
        backgroundColor: AppDesigns.primaryColor,
      ),
      body: Center(
        child: AppDesigns.customButton(
          title: 'Select Image',
          onPressed: _showImagePickerModal, // Show modal on button press
        ),
      ),
    );
  }
}
