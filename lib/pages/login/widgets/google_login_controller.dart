import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleLoginController extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      setLoading(true);

      // Force the account chooser by ending any existing session:
      await _googleSignIn.signOut(); // or: await _googleSignIn.disconnect();

      // Now show the chooser UI for the user to pick an account:
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _showSnackBar(context, 'Sign-in cancelled by user');
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      _showSnackBar(context, 'Failed to sign in: ${e.toString()}');
      return null;
    } finally {
      setLoading(false);
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      setLoading(true);
      await _googleSignIn.signOut();
      await _auth.signOut();
      _showSnackBar(context, 'Successfully signed out');
    } catch (e) {
      _showSnackBar(context, 'Failed to sign out: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(10),
      ),
    );
  }
}
