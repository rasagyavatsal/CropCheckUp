import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/adaptive/app_safe_area.dart';

void main() {
  group('AppSafeArea', () {
    testWidgets('top handles MediaQuery top padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(padding: EdgeInsets.only(top: 40)),
            child: AppSafeArea.top(
              child: const Text('Top Content'),
            ),
          ),
        ),
      );

      final padding = tester.widget<Padding>(
        find.ancestor(of: find.text('Top Content'), matching: find.byType(Padding)).first,
      );

      expect(padding.padding, const EdgeInsets.only(top: 40));
    });

    testWidgets('bottom handles MediaQuery bottom padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(padding: EdgeInsets.only(bottom: 30)),
            child: AppSafeArea.bottom(
              child: const Text('Bottom Content'),
            ),
          ),
        ),
      );

      final padding = tester.widget<Padding>(
        find.ancestor(of: find.text('Bottom Content'), matching: find.byType(Padding)).first,
      );

      expect(padding.padding, const EdgeInsets.only(bottom: 30));
    });
  });
}
