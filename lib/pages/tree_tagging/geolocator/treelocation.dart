import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:manggatectv2/services/button_design.dart';
import 'package:manggatectv2/utils/custom_page_transition.dart';
import '../../../services/app_designs.dart';
import '../tree_and_location_result/distplaytreeimage.dart';
import 'dart:io';

class TreeLocationPage extends StatefulWidget {
  final File image;
  final String username;

  const TreeLocationPage(
      {Key? key, required this.image, required this.username})
      : super(key: key);

  @override
  _TreeLocationPageState createState() => _TreeLocationPageState();
}

class _TreeLocationPageState extends State<TreeLocationPage> {
  String _locationMessage = '';
  bool _isLocationFetched = false;
  bool _isLoading = false;

  LatLng? _markerPosition; // Stores marker position

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        );

        setState(() {
          _markerPosition = LatLng(position.latitude,
              position.longitude); // Set initial marker position
          _locationMessage =
              'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
          _isLocationFetched = true;
        });
      } else {
        setState(() {
          _locationMessage = 'Location permission denied';
          _isLocationFetched = false;
        });
      }
    } catch (e) {
      setState(() {
        _locationMessage = 'Error getting location: $e';
        _isLocationFetched = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Get Tree Location',
          style: AppDesigns.titleTextStyle,
        ),
        backgroundColor: AppDesigns.primaryColor,
        elevation: 4,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Swap image + text with map + location once fetched
                if (!_isLocationFetched) ...[
                  Image.asset(
                    'assets/traveler.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Get close to the tree you want to tag.\nThen, adjust the marker if needed.',
                    style: AppDesigns.labelTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
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
                        SizedBox(
                          height: 250,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: _markerPosition!,
                              initialZoom: 18,
                              onTap: (tapPosition, point) {
                                setState(() {
                                  _markerPosition = point;
                                  _locationMessage =
                                      'Latitude: ${point.latitude}, Longitude: ${point.longitude}';
                                });
                              },
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
                                    point: _markerPosition!,
                                    width: 50.0,
                                    height: 50.0,
                                    child: GestureDetector(
                                      onPanUpdate: (details) {
                                        setState(() {
                                          _markerPosition = LatLng(
                                            _markerPosition!.latitude +
                                                details.delta.dy * 0.0001,
                                            _markerPosition!.longitude +
                                                details.delta.dx * 0.0001,
                                          );
                                          _locationMessage =
                                              'Latitude: ${_markerPosition!.latitude}, Longitude: ${_markerPosition!.longitude}';
                                        });
                                      },
                                      child: Image.asset(
                                        'assets/tree_icon.png',
                                        width: 40.0,
                                        height: 40.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _locationMessage,
                          style: AppDesigns.locationTextStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        FeatureCard(
                          title: "Continue",
                          icon: Icons.arrow_forward,
                          color: AppDesigns.primaryColor,
                          delay: 800,
                          onTap: () {
                            Navigator.push(
                              context,
                              PopTransition(
                                page: DisplayOutputPage(
                                  image: widget.image,
                                  location: _locationMessage,
                                  username: widget.username,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Always show this — stays even after location is fetched
                if (_isLoading)
                  AppDesigns.loadingIndicator()
                else
                  FeatureCard(
                    title: "Get Location",
                    icon: Icons.location_pin,
                    color: Colors.red,
                    delay: 0,
                    onTap: _getCurrentLocation,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
