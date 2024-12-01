import 'package:flutter/material.dart';
import 'package:manggatectv2/pages/history/historypage.dart';
import 'package:manggatectv2/pages/qrscanning/qrscannerpage.dart';
import 'package:manggatectv2/services/firestore.dart';
import 'package:manggatectv2/utility/custom_page_transition.dart';
import '../services/app_designs.dart';
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
        automaticallyImplyLeading: false, // Hides the back button
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: AppDesigns.primaryColor,
            ),
            tooltip: 'Information',
            onPressed: () {
              // Show a dialog or perform an action
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Information'),
                    content: const Text('This is an information dialog.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
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
                'MANGGATECH',
                style: AppDesigns.titleTextStyle3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 50,
              ),
              AppDesigns.customButton(
                title: "Scan QR Code",
                onPressed: () {
                  // Use the custom page transition
                  Navigator.push(
                    context,
                    CustomPageTransition(page: const QRScannerPage()),
                  );
                },
              ),
              const SizedBox(height: 5),
              AppDesigns.customButton(
                title: "Tag a Tree",
                onPressed: () {
                  // Use the custom page transition
                  Navigator.push(
                    context,
                    CustomPageTransition(page: const TreeTaggingPage()),
                  );
                },
              ),
              const SizedBox(height: 5),
              AppDesigns.customButton(
                title: "History",
                onPressed: () {
                  // Use the custom page transition
                  Navigator.push(
                    context,
                    BottomSlidePageTransition(page: const HistoryPage()),
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
