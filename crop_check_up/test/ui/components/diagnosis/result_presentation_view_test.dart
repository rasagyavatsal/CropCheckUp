import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/diagnosis/result_presentation_view.dart';
import 'package:crop_check_up/models/diagnosis_result.dart';
import 'package:crop_check_up/ui/theme/diagnosis_status_theme.dart';

void main() {
  group('ResultPresentationView', () {
    testWidgets('renders healthy result', (tester) async {
      const result = DiagnosisResult(
        rawLabel: 'Tomato___healthy',
        confidence: 0.95,
      );

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
            body: SingleChildScrollView(child: ResultPresentationView(result: result)),
          ),
        ),
      );

      expect(find.text('Healthy'), findsWidgets);
      expect(find.text('Maintenance Tips'), findsOneWidget);
    });

    testWidgets('renders disease result', (tester) async {
      const result = DiagnosisResult(
        rawLabel: 'Tomato___Late_blight',
        confidence: 0.95,
        symptoms: 'Brown spots\nYellow leaves',
        causes: 'Fungus',
        management: 'Use fungicide',
      );

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
            body: SingleChildScrollView(child: ResultPresentationView(result: result)),
          ),
        ),
      );

      expect(find.text('Disease Detected'), findsOneWidget);
      expect(find.text('Symptoms'), findsOneWidget);
      expect(find.text('Causes'), findsOneWidget);
      expect(find.text('Management & Treatment'), findsOneWidget);
    });
  });
}
