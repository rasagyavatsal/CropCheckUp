import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/layout/app_bottom_action_bar.dart';

void main() {
  group('AppBottomActionBar', () {
    testWidgets('wraps child with SafeArea and padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppBottomActionBar(
              child: const SizedBox(key: Key('child')),
            ),
          ),
        ),
      );

      final safeAreaFinder = find.byType(SafeArea);
      expect(safeAreaFinder, findsOneWidget);

      final paddingFinder = find.descendant(of: safeAreaFinder, matching: find.byType(Padding));
      expect(paddingFinder, findsWidgets);

      final safeArea = tester.widget<SafeArea>(safeAreaFinder);
      expect(safeArea.bottom, isTrue);
      expect(safeArea.top, isFalse);
    });
  });
}
