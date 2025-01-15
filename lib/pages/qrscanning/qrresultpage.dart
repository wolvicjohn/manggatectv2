import 'package:flutter/material.dart';
import 'package:manggatectv2/pages/qrscanning/image_pick.dart';
import 'package:manggatectv2/services/firestore.dart';
import 'package:manggatectv2/utility/custom_page_transition.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/app_designs.dart';

class QRResultPage extends StatefulWidget {
  final String qrResult;
  final String username;

  const QRResultPage({super.key, required this.qrResult, required this.username});

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
        CustomPageTransition(
          page: ImagePickPage(docID: docID, username: widget.username,),
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
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                          AppDesigns.customButton(
                            title: 'Classify',
                            onPressed: _navigateToClassifyPage,
                          ),
                          const SizedBox(height: 10),
                          AppDesigns.customButton(
                            title: 'Back to Scanner',
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}
