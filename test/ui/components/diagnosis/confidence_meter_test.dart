import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/diagnosis/confidence_meter.dart';
import 'package:crop_check_up/ui/theme/app_theme.dart';
import 'package:crop_check_up/ui/tokens/semantic_colors.dart';

void main() {
  group('ConfidenceMeter', () {
    testWidgets('renders confidence percentage', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: ConfidenceMeter(confidence: 0.85),
          ),
        ),
      );

      expect(find.text('85%'), findsOneWidget);
    });

    testWidgets('displays success color for percentage >= 80%', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: ConfidenceMeter(confidence: 0.80),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('80%'));
      expect(textWidget.style?.color, SemanticColors.light.success);
    });

    testWidgets('displays warning color for percentage between 50% and 79%', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: ConfidenceMeter(confidence: 0.50),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('50%'));
      expect(textWidget.style?.color, SemanticColors.light.warning);
    });

    testWidgets('displays danger color for percentage < 50%', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: ConfidenceMeter(confidence: 0.49),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('49%'));
      expect(textWidget.style?.color, SemanticColors.light.danger);
    });
  });
}
