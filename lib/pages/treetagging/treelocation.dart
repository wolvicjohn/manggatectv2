import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:manggatectv2/utility/custom_page_transition.dart';
import '../../services/app_designs.dart';
import 'distplaytreeimage.dart';
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
  bool _isLoading = false; // To track loading state

  // Function to get the current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      // Check for location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // Use LocationSettings for current position retrieval
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 10, // Update every 10 meters
          ),
        );
        setState(() {
          _locationMessage =
              'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
          _isLocationFetched =
              true; // Update state to indicate location fetched
        });
      } else {
        setState(() {
          _locationMessage = 'Location permission denied';
          _isLocationFetched =
              false; // Update state since location fetching failed
        });
      }
    } catch (e) {
      setState(() {
        _locationMessage = 'Error getting location: $e';
        _isLocationFetched =
            false; // Update state since location fetching failed
      });
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/traveler.png',
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 30),
              const Text(
                'Get close to the tree you want to tag.',
                style: AppDesigns.labelTextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                AppDesigns.loadingIndicator() // Show loading indicator
              else
                AppDesigns.customButton(
                  title: 'Get Location',
                  onPressed: _getCurrentLocation,
                ),
              const SizedBox(height: 20),
              if (_isLocationFetched) ...[
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _locationMessage,
                        style: AppDesigns.locationTextStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      AppDesigns.customButton(
                        title: 'Continue',
                        onPressed: () {
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
            ],
          ),
        ),
      ),
    );
  }
}
