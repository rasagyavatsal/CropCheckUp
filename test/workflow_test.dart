import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GitHub Actions workflow hardening', () {
    final file = File('.github/workflows/build.yml');
    expect(file.existsSync(), isTrue);
    final content = file.readAsStringSync();

    // 1. actions/setup-node should be pinned to a full commit SHA (40 hex chars)
    final setupNodeRegExp = RegExp(r'uses:\s*actions/setup-node@([a-fA-F0-9]{40})');
    expect(setupNodeRegExp.hasMatch(content), isTrue, reason: 'actions/setup-node must be pinned to a full commit SHA');

    // 2. npm ci should be run with --ignore-scripts
    expect(content.contains('npm ci --ignore-scripts'), isTrue, reason: 'npm ci must use --ignore-scripts');
  });
}
