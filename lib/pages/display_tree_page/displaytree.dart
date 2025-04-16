import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manggatectv2/pages/homepage/home_page.dart';
import 'package:manggatectv2/services/app_designs.dart';
import 'package:manggatectv2/services/button_design.dart';
import 'package:manggatectv2/utils/custom_page_transition.dart';

class LatestMangoTreeDisplay extends StatelessWidget {
  final String username;

  LatestMangoTreeDisplay({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String username = FirebaseAuth.instance.currentUser?.displayName ?? 'Guest';

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('mango_tree')
            .where('uploader', isEqualTo: username)
            .where('isArchived', isEqualTo: false)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: AppDesigns.loadingIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('No recent mango tree data found.',
                    style: TextStyle(fontSize: 16)));
          }

          var mangoTree = snapshot.data!.docs.first;
          var data = mangoTree.data() as Map<String, dynamic>;

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 32),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('ID: ${mangoTree.id}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          if (data['imageUrl'] != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(data['imageUrl'],
                                  height: 300, fit: BoxFit.cover),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FeatureCard(
                title: "Close",
                icon: Icons.done_rounded,
                color: AppDesigns.primaryColor,
                delay: 400,
                onTap: () => Navigator.pushAndRemoveUntil(
                  context,
                  CustomPageTransition(
                    page: Homepage(username: username),
                  ),
                  (Route<dynamic> route) => false,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
