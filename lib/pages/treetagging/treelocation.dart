import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/app_designs.dart';
import 'displayoutputpage.dart';
import 'dart:io';

class TreeLocationPage extends StatefulWidget {
  final File image; 

  const TreeLocationPage({Key? key, required this.image}) : super(key: key);

  @override
  _TreeLocationPageState createState() => _TreeLocationPageState();
}

class _TreeLocationPageState extends State<TreeLocationPage> {
  String _locationMessage = '';
  bool _isLocationFetched = false; 

  // Function to get the current location
  Future<void> _getCurrentLocation() async {
    try {
      // Check for location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _locationMessage =
              'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
          _isLocationFetched =
              true; // Update state to indicate location is fetched
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Get Tree Location',
          style: AppDesigns
              .titleTextStyle, // Use the title text style from AppDesigns
        ),
        backgroundColor:
            AppDesigns.primaryColor, // Use your primary color from AppDesigns
        elevation: 4, // Adjust elevation for a subtle shadow
        centerTitle: true, // Center the title
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Add padding around the column
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/traveler.png', // Replace with your image path
                width: 200, // Optional: set the width
                height: 200, // Optional: set the height
                fit: BoxFit
                    .cover, // Optional: adjust how the image should be fitted
              ),
              const SizedBox(height: 30),
              const Text(
                'Get close to the tree you want to tag.',
                style: AppDesigns.labelTextStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              AppDesigns.customButton(
                // Use custom button
                title: 'Get Location',
                onPressed: _getCurrentLocation,
              ),
              const SizedBox(height: 20),
              // Conditionally render the location message and Continue button together
              if (_isLocationFetched) ...[
                Container(
                  width: double
                      .infinity, // Stretch the container to fill the available width
                  padding: const EdgeInsets.all(
                      16.0), // Padding inside the container
                  decoration: BoxDecoration(
                    color: AppDesigns.backgroundColor, // Set background color
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26, // Shadow color
                        blurRadius: 4.0, // Shadow blur
                        offset: Offset(0, 2), // Shadow position
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // Use min size for the column
                    children: [
                      Text(
                        _locationMessage,
                        style: AppDesigns
                            .locationTextStyle, // Use location text style
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                          height: 10), // Space between text and button
                      AppDesigns.customButton(
                        // Use custom button
                        title: 'Continue',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DisplayOutputPage(
                                image: widget.image,
                                location:
                                    _locationMessage, // Pass the location here
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
