import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/diagnosis/result_summary_card.dart';
import 'package:crop_check_up/models/diagnosis_result.dart';
import 'package:crop_check_up/ui/theme/app_theme.dart';

void main() {
  group('ResultSummaryCard', () {
    testWidgets('renders result details', (tester) async {
      const result = DiagnosisResult(
        rawLabel: 'Tomato___Late_blight',
        confidence: 0.95,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: ResultSummaryCard(result: result),
          ),
        ),
      );

      expect(find.text('Crop: Tomato'), findsOneWidget);
      expect(find.text('Late blight'), findsOneWidget);
      expect(find.text('95%'), findsOneWidget);
      expect(find.text('Disease Detected'), findsOneWidget);
    });
  });
}

