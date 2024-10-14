import 'package:flutter/material.dart';
import 'package:manggatectv2/pages/qrscanning/qrscannerpage.dart';
import 'package:manggatectv2/services/firestore.dart';
import '../services/app_designs.dart';
import 'classify/classifypage.dart';
import 'treetagging/treetaggingpage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Homepage",
          style: AppDesigns
              .titleTextStyle, // Use the title text style from AppDesigns
        ),
        backgroundColor:
            AppDesigns.primaryColor, // Use your primary color from AppDesigns
        elevation: 4, // Adjust elevation for a subtle shadow
        centerTitle: true, // Center the title
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/mango.png', // Replace with your image path
              width: 300, // Optional: set the width
              height: 300, // Optional: set the height
              fit: BoxFit
                  .cover, // Optional: adjust how the image should be fitted
            ),
            Text(
              'MANGGATECT',
              style: AppDesigns.titleTextStyle3,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 30,
            ),
            AppDesigns.customButton(
              title: "Scan QR Code",
              onPressed: () {
                // Add navigation to QR code scanner page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const QRScannerPage()),
                );
              },
            ),
            const SizedBox(height: 15),
            AppDesigns.customButton(
              title: "Tag a Tree",
              onPressed: () {
                // Navigate to TreeTaggingPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TreeTaggingPage()),
                );
              },
            ),
            const SizedBox(height: 15),
            AppDesigns.customButton(
              title: "Classify",
              onPressed: () {
                // Add navigation to classify page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClassifyPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
