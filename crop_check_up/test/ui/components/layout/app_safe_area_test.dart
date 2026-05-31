import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/layout/app_safe_area.dart';

void main() {
  group('AppSafeArea', () {
    testWidgets('wraps child with SafeArea and configurable edges', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppSafeArea(
            top: true,
            bottom: false,
            child: const SizedBox(key: Key('child')),
          ),
        ),
      );

      final safeAreaFinder = find.byType(SafeArea);
      expect(safeAreaFinder, findsOneWidget);

      final SafeArea safeArea = tester.widget(safeAreaFinder);
      expect(safeArea.top, isTrue);
      expect(safeArea.bottom, isFalse);
    });
  });
}
