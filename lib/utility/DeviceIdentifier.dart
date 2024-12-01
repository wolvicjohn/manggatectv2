import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdentifier {
  static const String _deviceIdKey = 'device_id';

  /// Get or generate a unique device ID
  static Future<String> getDeviceId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if device ID is already saved locally
    String? deviceId = prefs.getString(_deviceIdKey);

    if (deviceId == null) {
      try {
        final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id; // Android unique ID
        }
        // Assign a fallback if no ID is available
        deviceId ??= 'unknown_device';

        // Save the device ID locally
        await prefs.setString(_deviceIdKey, deviceId);
      } catch (e) {
        // Handle potential errors (e.g., platform issues)
        deviceId = 'error_device';
      }
    }

    return deviceId;
  }
}
