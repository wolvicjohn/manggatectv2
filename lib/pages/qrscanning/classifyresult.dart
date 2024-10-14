import 'dart:io';
import 'package:flutter/material.dart';

import '../../services/firestore.dart'; // Adjust the import based on your project structure

class ClassifyResultPage extends StatefulWidget {
  final File image;
  final String docID; // Document ID for the QR data

  const ClassifyResultPage({required this.image, required this.docID, Key? key})
      : super(key: key);

  @override
  _ClassifyResultPageState createState() => _ClassifyResultPageState();
}

class _ClassifyResultPageState extends State<ClassifyResultPage> {
  bool _loading = false;
  String _result = "Classification Result"; // Placeholder for classification result
  String _description = "Description of the classification."; // Placeholder for description
  String? _stage; // Placeholder for the stage that will be updated

  @override
  void initState() {
    super.initState();
    // Add any initialization logic here
  }

  // Add a method to update the stage in Firestore
  Future<void> _updateStageInFirestore() async {
    FirestoreService firestoreService = FirestoreService();
    if (_stage != null) {
      try {
        await firestoreService.updateStage(
          docID: widget.docID, // Pass the document ID
          stage: _stage!, // Pass the stage to update
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stage updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating stage: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No stage to update!')),
      );
    }
  }

  // Placeholder for saving the stage; you can modify this logic as needed
  Future<void> _saveStageToFirestore() async {
    // Implement logic to save the stage if necessary
    // Example: setState(() { _stage = "New Stage"; });
  }

  // Build the loading view if needed
  Widget _buildLoadingView() {
    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classify Result'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _loading ? _buildLoadingView() : _buildResultView(),
        ),
      ),
    );
  }

  Widget _buildResultView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.file(widget.image),
        const SizedBox(height: 20),
        Text(
          _result,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          _description,
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _saveStageToFirestore, // Save original note
          child: const Text('Save Stage'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _updateStageInFirestore, // Update stage
          child: const Text('Update Stage'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
