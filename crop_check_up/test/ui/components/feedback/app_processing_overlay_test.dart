import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/feedback/app_processing_overlay.dart';

import 'package:crop_check_up/ui/theme/app_theme.dart';

void main() {
  group('AppProcessingOverlay', () {
    testWidgets('renders correctly and absorbs pointer', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Stack(
          children: [
            const Scaffold(body: Text('Background')),
            AppProcessingOverlay(
              message: 'Processing...',
            ),
          ],
        ),
      ));
      
      expect(find.text('Processing...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Should absorb pointer
      final absorbPointer = tester.widget<AbsorbPointer>(
        find.descendant(
          of: find.byType(AppProcessingOverlay),
          matching: find.byType(AbsorbPointer),
        ).first
      );
      expect(absorbPointer.absorbing, isTrue);
    });
  });
}
