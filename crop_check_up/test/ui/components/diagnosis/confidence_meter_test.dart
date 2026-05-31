import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/diagnosis/confidence_meter.dart';
import 'package:crop_check_up/ui/theme/diagnosis_status_theme.dart';

void main() {
  group('ConfidenceMeter', () {
    testWidgets('renders confidence percentage', (tester) async {
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
            body: ConfidenceMeter(confidence: 0.85),
          ),
        ),
      );

      expect(find.text('85%'), findsOneWidget);
    });
  });
}
