import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:manggatectv2/firebase_options.dart';
import 'package:manggatectv2/pages/login/GoogleSignIn.dart';
import 'package:manggatectv2/services/app_designs.dart';
import 'package:manggatectv2/utility/notificationservice.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  await checkForUpdate();
  await Future.delayed(const Duration(seconds: 1));
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

// Global Navigator Key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> checkForUpdate() async {
  final remoteConfig = FirebaseRemoteConfig.instance;

  try {
    // Set Remote Config settings
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    // Set default values
    await remoteConfig.setDefaults({'latest_version': '1.0.0'});

    // Fetch and activate remote configrR
    await remoteConfig.fetchAndActivate();

    // Get latest version from Remote Config
    String latestVersion = remoteConfig.getString('latest_version');

    // Get current app version
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    print("Current Version: $currentVersion");
    print("Latest Version from Remote Config: $latestVersion");

    // Check if an update is needed
    if (_isNewVersionAvailable(currentVersion, latestVersion)) {
      _showUpdateDialog();
    }
  } catch (e) {
    print("❌ Error checking update: $e");
  }
}

bool _isNewVersionAvailable(String current, String latest) {
  List<int> currentParts =
      current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  List<int> latestParts =
      latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();

  // Ensure both lists have the same length
  while (currentParts.length < latestParts.length) currentParts.add(0);
  while (latestParts.length < currentParts.length) latestParts.add(0);

  for (int i = 0; i < latestParts.length; i++) {
    if (latestParts[i] > currentParts[i]) return true;
    if (latestParts[i] < currentParts[i]) return false;
  }
  return false;
}

void _showUpdateDialog() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    BuildContext? context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.system_update, color: AppDesigns.primaryColor),
            const SizedBox(width: 10),
            const Text("Update Available"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "A new version is available with the latest features and improvements.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Later"),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              String updateUrl =
                  "https://drive.google.com/drive/folders/1Jprh_YyZ-ifAJBeAG0T5Nj12NrAnWubj?usp=sharing";
              Uri uri = Uri.parse(updateUrl);

              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text("Could not open update link. Please try again."),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppDesigns.primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.download),
                SizedBox(width: 8),
                Text("Update Now"),
              ],
            ),
          ),
        ],
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: GoogleLoginPage(),
    );
  }
}
