import 'package:flutter/material.dart';
import 'package:manggatectv2/pages/qrscanning/qrscannerpage.dart';
import 'package:manggatectv2/services/firestore.dart';
import '../services/app_designs.dart';
import 'classify(dont_include)/classifypage.dart';
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
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                'assets/mango.png',
                width: 250,
                height: 250,
                fit: BoxFit.cover,
              ),
              Text(
                'MANGGATECT',
                style: AppDesigns.titleTextStyle3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 50,
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
            ],
          ),
        ),
      ),
    );
  }
}
