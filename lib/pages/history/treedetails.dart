import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:manggatectv2/services/app_designs.dart';

import '../../utils/custom_page_transition.dart';
import '../qr_code_scanning/image_pick.dart';

class StageDetailsPage extends StatefulWidget {
  final String docId;
  final String username;

  const StageDetailsPage(
      {Key? key, required this.docId, required this.username})
      : super(key: key);

  @override
  _StageDetailsPageState createState() => _StageDetailsPageState();
}

class _StageDetailsPageState extends State<StageDetailsPage> {
  Map<String, dynamic>? data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final doc = await FirebaseFirestore.instance
        .collection('mango_tree')
        .doc(widget.docId)
        .get();

    if (doc.exists) {
      setState(() {
        data = doc.data();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tree Details'),
      ),
      body: isLoading
          ? Center(
              child: AppDesigns.loadingIndicator(),
            )
          : data == null
              ? const Center(child: Text("Tree not found."))
              : Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data!['stageImageUrl'] != null)
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(data!['stageImageUrl'],
                                      fit: BoxFit.cover,
                                      height: 200,
                                      width: 200),
                                ),
                              )
                            else
                              const Text("No image available."),
                            const SizedBox(height: 20),
                            if (data!['imageUrl'] != null)
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(data!['imageUrl'],
                                      fit: BoxFit.cover,
                                      height: 200,
                                      width: 200),
                                ),
                              )
                            else
                              const Text("No image available."),
                            const SizedBox(height: 20),
                            Text('Stage', style: AppDesigns.dataTextStyle),
                            Text('${data!['stage'] ?? 'Unknown'}',
                                style: AppDesigns.labelTextStyle),
                            const SizedBox(height: 10),
                            Divider(
                              color: Colors.grey,
                              thickness: 1,
                              height: 20,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Uploaded on',
                              style: AppDesigns.dataTextStyle,
                            ),
                            Text(
                              '${DateFormat('yyyy-MM-dd – kk:mm').format((data!['timestamp'] as Timestamp).toDate())}',
                              style: AppDesigns.labelTextStyle,
                            ),
                            const SizedBox(height: 10),
                            Divider(
                              color: Colors.grey,
                              thickness: 1,
                              height: 20,
                            ),
                            // map
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
                              child: SizedBox(
                                height: 200,
                                child: FlutterMap(
                                  options: MapOptions(
                                    initialCenter: LatLng(
                                      double.parse(data!['latitude']),
                                      double.parse(data!['longitude']),
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
                                            double.parse(data!['latitude']),
                                            double.parse(data!['longitude']),
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
                            ),
                            SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomRight,
                      margin: EdgeInsets.only(right: 20, bottom: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            CustomPageTransition(
                              page: ImagePickPage(
                                docID: widget.docId.toString(),
                                username: widget.username,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppDesigns.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 24.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.update,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Update',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
