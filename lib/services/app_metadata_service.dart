import 'package:flutter/services.dart';

class AppMetadataService {
  static const MethodChannel _channel = MethodChannel(
    'crop_check_up/app_metadata',
  );

  const AppMetadataService();

  Future<String?> loadVersion() async {
    try {
      final version = await _channel.invokeMethod<String>('getAppVersion');
      final normalizedVersion = version?.trim();
      if (normalizedVersion == null || normalizedVersion.isEmpty) {
        return null;
      }
      return normalizedVersion;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
