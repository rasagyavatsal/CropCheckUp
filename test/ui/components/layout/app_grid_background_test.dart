import 'package:crop_check_up/ui/components/layout/app_grid_background.dart';
import 'package:crop_check_up/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppGridBackground', () {
    testWidgets('uses a visible grid color in dark mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const AppGridBackground(child: SizedBox()),
        ),
      );

      final customPaint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(AppGridBackground),
          matching: find.byType(CustomPaint),
        ),
      );
      final painterColor = (customPaint.painter! as dynamic).color as Color;

      expect(painterColor.a, greaterThanOrEqualTo(0.10));
    });
  });
}
