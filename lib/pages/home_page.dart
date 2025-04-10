import 'package:flutter/material.dart';
import 'package:manggatectv2/pages/history/historypage.dart';
import 'package:manggatectv2/pages/login/GoogleSignIn.dart';
import 'package:manggatectv2/pages/map/alltreelocationpage.dart';
import 'package:manggatectv2/pages/qrscanning/qrscannerpage.dart';
import 'package:manggatectv2/pages/treetagging/camerapage.dart';
import 'package:manggatectv2/services/button_design.dart';
import 'package:manggatectv2/services/firestore.dart';
import 'package:manggatectv2/utility/custom_page_transition.dart';
import 'package:manggatectv2/services/app_designs.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Homepage extends StatefulWidget {
  final String username;
  Homepage({required this.username});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController titleController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _signOut() async {
    try {
      setState(() => _isLoading = true);
      await _googleSignIn.signOut();
      await _auth.signOut();

      // Navigate back to login page and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => GoogleLoginPage()),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully signed out'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
        ),
      );
    } catch (e) {
      print("Error during sign-out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign out: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: AppDesigns.primaryColor),
              SizedBox(width: 8),
              Text('About ManggaTech',
                  style: TextStyle(color: AppDesigns.primaryColor)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ManggaTech is your digital companion for mango tree management.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                '• Scan QR codes for quick tree identification\n'
                '• Tag and track individual trees\n'
                '• View complete history of tree management\n'
                '• Access interactive map of all trees',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Got it',
                  style: TextStyle(color: AppDesigns.primaryColor)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade100],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: FadeInDown(
                    duration: Duration(milliseconds: 800),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppDesigns.primaryColor,
                            AppDesigns.primaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Hero(
                            tag: 'app_logo',
                            child: Image.asset(
                              'assets/mango.png',
                              width: 80,
                              height: 80,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'MANGGATECH',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.info_outline, color: Colors.white),
                    onPressed: _showInfoDialog,
                  ),
                  IconButton(
                    icon: Icon(Icons.logout, color: Colors.white),
                    onPressed: _isLoading ? null : _signOut,
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    FadeInDown(
                      duration: Duration(milliseconds: 800),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppDesigns.primaryColor,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  widget.username,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            if (_isLoading)
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: AppDesigns.loadingIndicator()
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    FeatureCard(
                      title: "Scan QR Code",
                      icon: Icons.qr_code_scanner,
                      color: Color(0xFF4CAF50),
                      delay: 200,
                      onTap: () => Navigator.push(
                        context,
                        CustomPageTransition(
                          page: QRScannerPage(username: widget.username),
                        ),
                      ),
                    ),
                    FeatureCard(
                      title: "Tag a Tree",
                      icon: Icons.local_florist,
                      color: Color(0xFF2196F3),
                      delay: 400,
                      onTap: () => Navigator.push(
                        context,
                        CustomPageTransition(
                          page: ImagePickerPage(username: widget.username),
                        ),
                      ),
                    ),
                    FeatureCard(
                      title: "History",
                      icon: Icons.history,
                      color: Color(0xFF9C27B0),
                      delay: 600,
                      onTap: () => Navigator.push(
                        context,
                        BottomSlidePageTransition(
                            page: HistoryPage(
                          username: widget.username,
                        )),
                      ),
                    ),
                    FeatureCard(
                      title: "Map",
                      icon: Icons.map,
                      color: Color(0xFFFF9800),
                      delay: 800,
                      onTap: () => Navigator.push(
                        context,
                        BottomSlidePageTransition(
                          page: AllTreeLocationPage(username: widget.username),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
