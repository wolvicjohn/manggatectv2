import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:manggatectv2/services/app_designs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

class AllTreeLocationPage extends StatefulWidget {
  final String username;
  const AllTreeLocationPage({Key? key, required this.username})
      : super(key: key);

  @override
  AllTreeLocationPageState createState() => AllTreeLocationPageState();
}

class AllTreeLocationPageState extends State<AllTreeLocationPage> {
  String selectedStage = 'All Stages';
  List<String> stages = [
    'All Stages',
    'stage-1',
    'stage-2',
    'stage-3',
    'stage-4'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tree Locations',
          style: AppDesigns.titleTextStyle,
        ),
        backgroundColor: AppDesigns.primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('mango_tree')
                        .where('uploader', isEqualTo: widget.username)
                        .where('isArchived', isEqualTo: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: AppDesigns.loadingIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      // Get all tree locations based on selectedStage
                      final List<LatLng> locations =
                          snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return selectedStage == 'All Stages' ||
                            data['stage'] ==
                                selectedStage; // Show all or filter
                      }).map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return LatLng(
                          double.parse(data['latitude'].toString()),
                          double.parse(data['longitude'].toString()),
                        );
                      }).toList();

                      // Show a message if there are no locations for the selected stage
                      if (locations.isEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('No data available for $selectedStage.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        });
                      }

                      return FlutterMap(
                        options: MapOptions(
                          initialCenter: locations.isNotEmpty
                              ? locations[0]
                              : const LatLng(0, 0),
                          initialZoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.app',
                          ),
                          MarkerLayer(
                            markers: locations.map((location) {
                              // Find the corresponding document to get its 'stage'
                              final doc = snapshot.data!.docs.firstWhere((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return double.parse(
                                            data['latitude'].toString()) ==
                                        location.latitude &&
                                    double.parse(
                                            data['longitude'].toString()) ==
                                        location.longitude;
                              });
                              final data = doc.data() as Map<String, dynamic>;
                              final stage = data['stage'];
                              final timestamp =
                                  DateFormat('EEEE, MMMM dd, yyyy h:mm a')
                                      .format(data['timestamp'].toDate());
                              final String? imageUrl = data['imageUrl'];
                              final String? stageImageUrl =
                                  data['stageImageUrl'];

                              String iconPath;
                              switch (stage) {
                                case 'stage-1':
                                  iconPath = 'assets/tree_icon.png';
                                  break;
                                case 'stage-2':
                                  iconPath = 'assets/stage1_icon.png';
                                  break;
                                case 'stage-3':
                                  iconPath = 'assets/stage2_icon.png';
                                  break;
                                case 'stage-4':
                                  iconPath = 'assets/stage3_icon.png';
                                  break;
                                default:
                                  iconPath = 'assets/mango.png';
                              }

                              return Marker(
                                point: location,
                                width: 50.0,
                                height: 50.0,
                                child: GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.white,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20)),
                                      ),
                                      barrierColor: Colors.transparent,
                                      builder: (context) {
                                        return Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child:
                                                        data['imageUrl'] != null
                                                            ? ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                                child: CachedNetworkImage(
                                                                    imageUrl: imageUrl!,
                                                                    width: 100,
                                                                    height: 100,
                                                                    fit: BoxFit.cover,
                                                                    placeholder: (context, url) => Container(
                                                                        width: 100,
                                                                        height: 100,
                                                                        padding: const EdgeInsets.all(20),
                                                                        decoration: BoxDecoration(
                                                                          color:
                                                                              Colors.white,
                                                                          borderRadius:
                                                                              BorderRadius.circular(20),
                                                                        ),
                                                                        child: AppDesigns.loadingIndicator()),
                                                                    errorWidget: (context, url, error) => Container(
                                                                          width:
                                                                              60,
                                                                          height:
                                                                              60,
                                                                          color: Colors
                                                                              .grey
                                                                              .shade200,
                                                                          child:
                                                                              const Icon(Icons.error_outline),
                                                                        )),
                                                              )
                                                            : Container(
                                                                width: 60,
                                                                height: 60,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade200,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                ),
                                                                child: const Icon(
                                                                    Icons
                                                                        .image_not_supported_outlined),
                                                              ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child:
                                                        data['stageImageUrl'] !=
                                                                null
                                                            ? ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                                child: CachedNetworkImage(
                                                                    imageUrl: stageImageUrl!,
                                                                    width: 100,
                                                                    height: 100,
                                                                    fit: BoxFit.cover,
                                                                    placeholder: (context, url) => Container(
                                                                        width: 100,
                                                                        height: 100,
                                                                        padding: const EdgeInsets.all(20),
                                                                        decoration: BoxDecoration(
                                                                          color:
                                                                              Colors.white,
                                                                          borderRadius:
                                                                              BorderRadius.circular(20),
                                                                        ),
                                                                        child: AppDesigns.loadingIndicator()),
                                                                    errorWidget: (context, url, error) => Container(
                                                                          width:
                                                                              60,
                                                                          height:
                                                                              60,
                                                                          color: Colors
                                                                              .grey
                                                                              .shade200,
                                                                          child:
                                                                              const Icon(Icons.error_outline),
                                                                        )),
                                                              )
                                                            : Container(
                                                                width: 60,
                                                                height: 60,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade200,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                ),
                                                                child: const Icon(
                                                                    Icons
                                                                        .image_not_supported_outlined),
                                                              ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              Text('$stage',
                                                  style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              const SizedBox(height: 10),
                                              const Divider(),
                                              const Text('Uploaded on',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey)),
                                              Text(timestamp,
                                                  style: const TextStyle(
                                                      fontSize: 16)),
                                              const Divider()
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Image.asset(
                                    iconPath,
                                    width: 40.0,
                                    height: 40.0,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          RichAttributionWidget(
                            attributions: [
                              TextSourceAttribution(
                                'OpenStreetMap contributors',
                                onTap: () => launchUrl(Uri.parse(
                                    'https://www.openstreetmap.org/copyright')),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10.0,
                  left: 1.0,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: DropdownButton<String>(
                      value: selectedStage,
                      icon: const Icon(Icons.arrow_downward,
                          color: Colors.black87),
                      elevation: 16,
                      style: const TextStyle(color: Colors.black87),
                      dropdownColor: Colors.white,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedStage = newValue!;
                        });
                      },
                      items:
                          stages.map<DropdownMenuItem<String>>((String stage) {
                        return DropdownMenuItem<String>(
                          value: stage,
                          child: Text(stage),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Dropdown button for selecting stages
                Positioned(
                  top: 15.0,
                  right: 15.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Column(
                          children: [
                            Container(
                              margin: EdgeInsets.all(5),
                              child: const Text(
                                'LEGEND',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Image.asset(
                                      'assets/tree_icon.png',
                                      height: 40,
                                      width: 40,
                                    ),
                                    const Text('Stage 1'),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Column(
                                  children: [
                                    Image.asset(
                                      'assets/stage1_icon.png',
                                      height: 40,
                                      width: 40,
                                    ),
                                    const Text('Stage 2'),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Column(
                                  children: [
                                    Image.asset(
                                      'assets/stage2_icon.png',
                                      height: 40,
                                      width: 40,
                                    ),
                                    const Text('Stage 3'),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Column(
                                  children: [
                                    Image.asset(
                                      'assets/stage3_icon.png',
                                      height: 40,
                                      width: 40,
                                    ),
                                    const Text('Stage 4'),
                                  ],
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
