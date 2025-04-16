import 'package:flutter/material.dart';
import 'package:manggatectv2/pages/qr_code_scanning/image_pick.dart';
import 'package:manggatectv2/services/button_design.dart';
import 'package:manggatectv2/services/firestore.dart';
import 'package:manggatectv2/utils/custom_page_transition.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../services/app_designs.dart';

class QRResultPage extends StatefulWidget {
  final String qrResult;
  final String username;

  const QRResultPage(
      {super.key, required this.qrResult, required this.username});

  @override
  State<QRResultPage> createState() => _QRResultPageState();
}

class _QRResultPageState extends State<QRResultPage> {
  final FirestoreService firestoreService = FirestoreService();
  Map<String, dynamic>? docData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDocData();
  }

  Future<void> _fetchDocData() async {
    try {
      // Attempt to retrieve the mango_tree using the scanned QR code as the docID
      final data = await firestoreService.getmango_treeById(widget.qrResult);

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
        errorMessage =
            'Oops! The QR code you scanned is not available or deleted. Please try another QR code!.';
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
        CustomPageTransition(
          page: ImagePickPage(
            docID: docID,
            username: widget.username,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String? ImageUrl = docData?['imageUrl'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Result'),
        backgroundColor: AppDesigns.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: isLoading
              ? AppDesigns.loadingIndicator()
              : errorMessage.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 40.0),
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.redAccent),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red.shade700, size: 50),
                            const SizedBox(height: 15),
                            Text(
                              "Oops!",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              errorMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(height: 25),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.qr_code_scanner),
                              label: const Text("Try Again"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                            child: Column(
                              children: [
                                Image.network(ImageUrl!),
                                Divider(
                                  color: Colors.grey,
                                ),
                                Text(
                                  'ID: ${widget.qrResult}\n'
                                  'Stage: ${docData!['stage'] ?? 'No data yet'}',
                                  textAlign: TextAlign.center,
                                  style: AppDesigns.labelTextStyle,
                                ),
                                Divider(
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 20),
                                // FlutterMap implementation
                                SizedBox(
                                  height: 200,
                                  child: FlutterMap(
                                    options: MapOptions(
                                      initialCenter: LatLng(
                                        double.parse(docData!['latitude']),
                                        double.parse(docData!['longitude']),
                                      ),
                                      initialZoom: 15,
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName: 'com.example.app',
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            point: LatLng(
                                              double.parse(
                                                  docData!['latitude']),
                                              double.parse(
                                                  docData!['longitude']),
                                            ),
                                            width: 50.0,
                                            height: 50.0,
                                            child: Image.asset(
                                              'assets/tree_icon.png',
                                              width: 40.0,
                                              height: 40.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          FeatureCard(
                            title: "Classify",
                            icon: Icons.arrow_forward,
                            color: AppDesigns.primaryColor,
                            delay: 600,
                            onTap: _navigateToClassifyPage,
                          ),
                          const SizedBox(height: 10),
                          FeatureCard(
                            title: "Scan Again",
                            icon: Icons.qr_code_scanner,
                            color: Color(0xFF2196F3),
                            delay: 600,
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}
