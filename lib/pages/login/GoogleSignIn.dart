import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manggatectv2/pages/home_page.dart';
import 'package:manggatectv2/services/app_designs.dart';

class GoogleLoginPage extends StatefulWidget {
  @override
  _GoogleLoginPageState createState() => _GoogleLoginPageState();
}

class _GoogleLoginPageState extends State<GoogleLoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<User?> _signInWithGoogle() async {
    try {
      setState(() => _isLoading = true);

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in cancelled by user')),
        );
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Error during sign-in: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in: ${e.toString()}')),
      );
      return null;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    try {
      setState(() => _isLoading = true);
      await _googleSignIn.signOut();
      await _auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully signed out')),
      );
    } catch (e) {
      print("Error during sign-out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign out: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppDesigns.primaryColor,
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // Add logo or image
                      Image.asset(
                        'assets/mango.png', // Make sure to add the logo in your assets folder
                        height: 100,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Sign in to continue',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 30),
                      // Sign-in button
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                User? user = await _signInWithGoogle();
                                if (user != null) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Homepage(
                                        username: user.displayName ?? 'Guest',
                                      ),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Button color
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.login, color: Colors.black),
                            SizedBox(width: 10),
                            Text('Sign in with Google',
                                style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      // Sign-out button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _signOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent, // Button color
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Sign out',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
