import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/layout/app_scroll_wrapper.dart';

void main() {
  group('AppScrollWrapper', () {
    testWidgets('makes child scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppScrollWrapper(
            child: Container(
              height: 2000,
              color: Colors.red,
            ),
          ),
        ),
      );

      final scrollViewFinder = find.byType(SingleChildScrollView);
      expect(scrollViewFinder, findsOneWidget);
    });
  });
}
