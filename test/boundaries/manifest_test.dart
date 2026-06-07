import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Android Manifest Configuration (Issue #97)', () {
    test('usesCleartextTraffic is set to false in AndroidManifest.xml', () {
      final manifestFile = File('android/app/src/main/AndroidManifest.xml');
      expect(manifestFile.existsSync(), isTrue, reason: 'AndroidManifest.xml should exist');
      
      final content = manifestFile.readAsStringSync();
      
      // Parse the content. We look for usesCleartextTraffic="false" inside <application ... >
      // We can use a RegExp or simple string checks.
      expect(content, contains('android:usesCleartextTraffic="false"'), 
          reason: 'AndroidManifest.xml must set android:usesCleartextTraffic="false" to disable cleartext traffic explicitly.');
    });
  });

  group('Android Manifest Configuration (Issue #98)', () {
    test('camera permission and hardware features config', () {
      final manifestFile = File('android/app/src/main/AndroidManifest.xml');
      expect(manifestFile.existsSync(), isTrue, reason: 'AndroidManifest.xml should exist');
      
      final content = manifestFile.readAsStringSync();
      
      expect(content, contains('<uses-permission android:name="android.permission.CAMERA" />'),
          reason: 'AndroidManifest.xml must declare android.permission.CAMERA permission for scanning');
      
      expect(content, contains('<uses-feature android:name="android.hardware.camera" android:required="false" />'),
          reason: 'android.hardware.camera feature must be optional (required="false")');
      
      expect(content, contains('<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />'),
          reason: 'android.hardware.camera.autofocus feature must be optional (required="false")');
    });
  });
}
