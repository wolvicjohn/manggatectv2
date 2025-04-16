import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:manggatectv2/pages/homepage/home_page.dart';
import 'package:manggatectv2/services/button_design.dart';
import 'package:manggatectv2/utils/custom_page_transition.dart';
import 'dart:io';
import '../../../services/app_designs.dart';
import '../../../services/firestore.dart';
import 'package:image/image.dart' as img;

import '../image_pick.dart';

class DisplayOutputPage extends StatefulWidget {
  final File image;
  final String location;
  final String username;

  const DisplayOutputPage({
    Key? key,
    required this.image,
    required this.location,
    required this.username,
  }) : super(key: key);

  @override
  _DisplayOutputPageState createState() => _DisplayOutputPageState();
}

class _DisplayOutputPageState extends State<DisplayOutputPage> {
  bool _isLoading = false;

  File _resizeImageFile(File originalFile) {
    final originalImage = img.decodeImage(originalFile.readAsBytesSync())!;
    final resizedImage = img.copyResize(originalImage, width: 224, height: 224);
    final resizedBytes = img.encodeJpg(resizedImage);

    final resizedFile = File(
        '${originalFile.parent.path}/resized_${originalFile.uri.pathSegments.last}');
    resizedFile.writeAsBytesSync(resizedBytes);

    return resizedFile;
  }

  // Function to parse location
  List<String> parseLocation() {
    return widget.location.split(', ').map((e) => e.split(': ')[1]).toList();
  }

  // Function to save the mango_tree to Firestore
  Future<void> savemango_tree() async {
    List<String> latLon = parseLocation();
    String latitude = latLon[0];
    String longitude = latLon[1];

    FirestoreService firestoreService = FirestoreService();
    bool classifyChecked = false;

    try {
      setState(() {
        _isLoading = true;
      });

      // Show custom dialog with checkbox
      bool? saveConfirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: AppDesigns.backgroundColor,
                title: const Text(
                  'Do you want to save this tree?',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                      value: classifyChecked,
                      onChanged: (value) {
                        setState(() {
                          classifyChecked = value ?? false;
                        });
                      },
                      title: const Text(
                        'Do you want to classify this tree?',
                        style: TextStyle(color: Colors.black),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      activeColor: Color.fromARGB(
                          255, 20, 116, 82),
                      checkColor: Colors.white,
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('No', style: AppDesigns.labelTextStyle),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Yes', style: AppDesigns.labelTextStyle),
                  ),
                ],
              );
            },
          );
        },
      );

      if (saveConfirmed == true) {
        if (classifyChecked) {
          // Redirect to classify without saving
          Navigator.push(
            context,
            CustomPageTransition(
              page: ClassifyPage(
                latitude: latitude,
                longitude: longitude,
                image: widget.image,
                username: widget.username,
              ),
            ),
          );
        } else {
          // Resize and save to Firestore
          File resizedImageFile = _resizeImageFile(widget.image);

          await firestoreService.addmango_tree(
            longitude: longitude,
            latitude: latitude,
            image: resizedImageFile,
            stageImage: null,
            isArchived: false,
            uploader: widget.username,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tree saved successfully!')),
          );

          Navigator.pushReplacement(
            context,
            CustomPageTransition(page: Homepage(username: widget.username)),
          );
        }
      }
    } catch (e) {
      log('Error saving mango_tree: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving mango_tree: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> latLon = parseLocation();
    String latitude = latLon[0];
    String longitude = latLon[1];

    return Scaffold(
      appBar: AppBar(
        title: Text('Tag a Tree', style: AppDesigns.titleTextStyle),
        backgroundColor: AppDesigns.primaryColor,
        elevation: 4,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Image display
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        widget.image,
                        height: 300,
                        width: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Location display inside a container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppDesigns.backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Latitude:',
                            style: AppDesigns.labelTextStyle,
                          ),
                          Text(
                            latitude,
                            style: AppDesigns.valueTextStyle,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Longitude:',
                            style: AppDesigns.labelTextStyle,
                          ),
                          Text(
                            longitude,
                            style: AppDesigns.valueTextStyle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Custom Save button
                    FeatureCard(
                      title: "Save",
                      icon: Icons.save,
                      color: AppDesigns.primaryColor,
                      delay: 800,
                      onTap: savemango_tree,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Show loading indicator if _isLoading is true
          if (_isLoading)
            Opacity(
              opacity: 0.5,
              child: ModalBarrier(
                dismissible: false,
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          if (_isLoading)
            Center(
              child: AppDesigns.loadingIndicator(),
            ),
        ],
      ),
    );
  }
}
