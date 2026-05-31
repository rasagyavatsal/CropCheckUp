import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/diagnosis/status_badge.dart';
import 'package:crop_check_up/ui/theme/diagnosis_status_theme.dart';

void main() {
  group('StatusBadge', () {
    testWidgets('renders correct text and color for healthy', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [
              DiagnosisStatusTheme(
                healthyColor: Colors.green,
                dangerColor: Colors.red,
                warningColor: Colors.orange,
                neutralColor: Colors.grey,
              )
            ],
          ),
          home: const Scaffold(
            body: StatusBadge(isHealthy: true),
          ),
        ),
      );

      expect(find.text('Healthy'), findsOneWidget);
    });

    testWidgets('renders correct text and color for disease', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [
              DiagnosisStatusTheme(
                healthyColor: Colors.green,
                dangerColor: Colors.red,
                warningColor: Colors.orange,
                neutralColor: Colors.grey,
              )
            ],
          ),
          home: const Scaffold(
            body: StatusBadge(isHealthy: false),
          ),
        ),
      );

      expect(find.text('Disease Detected'), findsOneWidget);
    });
  });
}
