import 'package:flutter/material.dart';
import 'dart:io';
import '../../services/app_designs.dart';
import '../../services/firestore.dart';
import 'classify_page.dart';

class DisplayOutputPage extends StatefulWidget {
  final File? image;
  final String location;

  const DisplayOutputPage({
    Key? key,
    required this.image,
    required this.location,
  }) : super(key: key);

  @override
  _DisplayOutputPageState createState() => _DisplayOutputPageState();
}

class _DisplayOutputPageState extends State<DisplayOutputPage> {
  bool _isLoading = false; // Track loading state

  // Function to parse location
  List<String> parseLocation() {
    return widget.location.split(', ').map((e) => e.split(': ')[1]).toList();
  }

  // Function to save the note to Firestore
  Future<void> saveNote() async {
    List<String> latLon = parseLocation();
    String latitude = latLon[0];
    String longitude = latLon[1];

    FirestoreService firestoreService = FirestoreService();

    try {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      // Ask user if they want to classify the tree now
      bool? classifyNow = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor:
                AppDesigns.backgroundColor, // Custom background color
            content: const Column(
              mainAxisSize: MainAxisSize.min, // Adjust size to content
              children: [
                const Text(
                  'Do you want to classify this tree now?\nNote: This is optional',
                  style: TextStyle(fontSize: 16), // Custom content text size
                  textAlign:
                      TextAlign.center, // Center align for better aesthetics
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'No',
                  style: AppDesigns.labelTextStyle, // Custom button text style
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Yes',
                  style: AppDesigns.labelTextStyle, // Custom button text style
                ),
              ),
            ],
          );
        },
      );

      // Save the note with image and location to Firestore
      await firestoreService.addNote(
        longitude: longitude,
        latitude: latitude,
        image: widget.image!, // Ensure image is not null
      );

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tree saved successfully!')),
      );

      // If user confirms to classify, navigate to ClassifyPage
      if (classifyNow == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ClassifyPage(
                    latitude: latitude,
                    longitude: longitude,
                  )),
        );
      }
    } catch (e) {
      print('Error saving note: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving note: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
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
        title: Text(
          'Tag a Tree',
          style: AppDesigns.titleTextStyle,
        ),
        backgroundColor: AppDesigns.primaryColor,
        elevation: 4,
        centerTitle: true,
      ),
      body: Center(
        child: _isLoading // Show loading indicator while saving
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Image with border radius
                    widget.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              widget.image!,
                              height: 400,
                              width: 400,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Text('No image selected'),
                    const SizedBox(height: 20),
                    // Display latitude and longitude with styling in a Container
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
                    const SizedBox(height: 100),
                    // Use the custom button from AppDesigns
                    AppDesigns.customButton(
                      title: 'Save',
                      onPressed: saveNote,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
