import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:manggatectv2/pages/home_page.dart';
import 'package:manggatectv2/pages/treetagging/image_pick.dart';
import 'package:manggatectv2/utility/custom_page_transition.dart';
import 'dart:io';
import '../../services/app_designs.dart';
import '../../services/firestore.dart';

class DisplayOutputPage extends StatefulWidget {
  final File image;
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

  // Function to save the mango_tree to Firestore
  Future<void> savemango_tree() async {
    List<String> latLon = parseLocation();
    String latitude = latLon[0];
    String longitude = latLon[1];

    FirestoreService firestoreService = FirestoreService();

    try {
      setState(() {
        _isLoading = true; // Show loading indicator while saving
      });

      // Show save confirmation dialog
      // Show save confirmation dialog
      bool? saveNow = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AppDesigns.customDialog(
            context: context,
            title: 'Do you want to save this?',
            content: '',
            onYes: () => Navigator.of(context).pop(true),
            onNo: () => Navigator.of(context).pop(false),
          );
        },
      );

      if (saveNow == false) {
        return;
      }

      // Ask user if they want to classify the tree now
      bool? classifyNow = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppDesigns.backgroundColor,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Do you want to classify this tree now?\n',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors
                          .black), // You can modify the text color here if necessary
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'No',
                  style: AppDesigns.labelTextStyle,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Yes',
                  style: AppDesigns.labelTextStyle,
                ),
              ),
            ],
          );
        },
      );

      // If user confirms to classify, navigate to ClassifyPage
      if (classifyNow == true) {
        Navigator.push(
          context,
          CustomPageTransition(
            page: ClassifyPage(
              latitude: latitude,
              longitude: longitude,
              image: widget.image,
            ),
          ),
        );
      } else if (classifyNow == false) {
        // Save the mango_tree with image and location to Firestore
        await firestoreService.addmango_tree(
          longitude: longitude,
          latitude: latitude,
          image: widget.image,
          stageImage: null,
          isArchived: false,
        );

        // Show a success message if saved
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tree saved successfully!')),
        );
      }
    } catch (e) {
      log('Error saving mango_tree: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving mango_tree: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator after completion
      });
      Navigator.pushReplacement(
        context,
        CustomPageTransition(page: const Homepage()),
      );
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
                    AppDesigns.customButton(
                      title: 'Save',
                      onPressed: savemango_tree,
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
