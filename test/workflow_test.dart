import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GitHub Actions workflow hardening', () {
    final file = File('.github/workflows/build.yml');
    expect(file.existsSync(), isTrue);
    final content = file.readAsStringSync();

    // 1. actions/setup-node should use a version tag, not a full commit SHA.
    final setupNodeRegExp = RegExp(r'uses:\s*actions/setup-node@([^\s#]+)');
    final setupNodeMatch = setupNodeRegExp.firstMatch(content);
    expect(
      setupNodeMatch,
      isNotNull,
      reason: 'actions/setup-node must be configured',
    );

    final setupNodeRef = setupNodeMatch!.group(1)!;
    expect(
      setupNodeRef.startsWith('v'),
      isTrue,
      reason: 'actions/setup-node must use a version tag',
    );
    expect(
      RegExp(r'^[a-fA-F0-9]{40}$').hasMatch(setupNodeRef),
      isFalse,
      reason: 'actions/setup-node must not be pinned to a full commit SHA',
    );

    // 2. npm ci should be run with --ignore-scripts
    expect(
      content.contains('npm ci --ignore-scripts'),
      isTrue,
      reason: 'npm ci must use --ignore-scripts',
    );
  });
}
