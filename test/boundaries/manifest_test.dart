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
}
