import 'package:flutter/material.dart';
import 'package:manggatectv2/pages/qrscanning/image_pick.dart';
import 'package:manggatectv2/services/firestore.dart';
import '../../services/app_designs.dart';

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

  /// Method to navigate to the Classify page
  void _navigateToClassifyPage() {
    if (docData != null) {
      String docID = widget.qrResult;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePickPage(docID: docID), 
        ),
      );
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
                            'DocID: ${widget.qrResult}\n'
                            'Longitude: ${docData!['longitude']}\n'
                            'Latitude: ${docData!['latitude']}\n'
                            'Stage: ${docData!['stage'] ?? 'No data yet'}',
                            textAlign: TextAlign.center,
                            style: AppDesigns.labelTextStyle,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AppDesigns.customButton(
                          title: 'Classify',
                          onPressed: _navigateToClassifyPage, // Always navigate to classify page
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
