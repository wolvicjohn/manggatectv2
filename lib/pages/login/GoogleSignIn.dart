import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'widgets/google_login_controller.dart';
import 'widgets/google_login_ui.dart';

class GoogleLoginPage extends StatefulWidget {
  @override
  _GoogleLoginPageState createState() => _GoogleLoginPageState();
}

class _GoogleLoginPageState extends State<GoogleLoginPage> {
  final GoogleLoginController _controller = GoogleLoginController();

  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    final status = await Permission.notification.status;

    if (!status.isGranted) {
      final result = await Permission.notification.request();

      if (!result.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Notifications are disabled. You might miss important updates."),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(12),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleLoginUI(controller: _controller);
  }
}
