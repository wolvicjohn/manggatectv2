import 'package:flutter/material.dart';
import 'package:manggatectv2/services/firestore.dart';
import '../../services/app_designs.dart';
import '../treetagging/classify_page.dart';

class QRResultPage extends StatefulWidget {
  final String qrResult;

  const QRResultPage({super.key, required this.qrResult});

  @override
  State<QRResultPage> createState() => _QRResultPageState();
}

class _QRResultPageState extends State<QRResultPage> {
  final FirestoreService firestoreService = FirestoreService();
  Map<String, dynamic>? docData; // Store the document data
  bool isLoading = true; // Track loading state
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDocData();
  }

  Future<void> _fetchDocData() async {
    try {
      // Attempt to retrieve the document using the scanned QR code as the docID
      final data = await firestoreService.getNoteById(widget.qrResult);

      if (data.isNotEmpty) {
        setState(() {
          docData = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'No data found for this QR code.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  /// Method to handle navigation to Classify or Update page
  void _navigateToPage(String routeName) {
    if (docData != null) {
      Navigator.pushNamed(
        context,
        routeName,
        arguments: docData, // Pass the document data as arguments
      );
    }
  }

  void _handleClassifyOrUpdate() {
    if (docData != null) {
      print('Document Data: $docData'); // Debug print
      if (docData!['stage'] == null || docData!['stage'] == 'No data yet') {
        // Retrieve latitude, longitude, and docID from docData
        String latitude = docData!['latitude'] ?? '';
        String longitude = docData!['longitude'] ?? '';
        String docID = widget.qrResult; // Use the qrResult as docID

        // Navigate to classify page with latitude, longitude, and docID
        print('Navigating to Classify Page'); // Debug print
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClassifyPage(
              
              latitude: latitude,
              longitude: longitude,
            ),
          ),
        );
      } else {
        // Navigate to update page
        print('Navigating to Update Page'); // Debug print
        _navigateToPage('/update');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Result'),
        backgroundColor: AppDesigns.primaryColor,
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : errorMessage.isNotEmpty
                ? Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Tree Data:',
                          style: AppDesigns.titleTextStyle2,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: AppDesigns.backgroundColor,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4.0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Title: ${docData!['title']}\n'
                            'Longitude: ${docData!['longitude']}\n'
                            'Latitude: ${docData!['latitude']}\n'
                            'Stage: ${docData!['stage'] ?? 'No data yet'}',
                            textAlign: TextAlign.center,
                            style: AppDesigns.labelTextStyle,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AppDesigns.customButton(
                          title: docData != null &&
                                  (docData!['stage'] == null ||
                                      docData!['stage'] == 'No data yet')
                              ? 'Classify'
                              : 'Update',
                          onPressed: () {
                            print('Button Pressed');
                            _handleClassifyOrUpdate();
                          },
                        ),
                        const SizedBox(height: 20),
                        AppDesigns.customButton(
                          title: 'Back to Scanner',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
