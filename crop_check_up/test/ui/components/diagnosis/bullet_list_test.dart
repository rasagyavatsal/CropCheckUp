import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/diagnosis/bullet_list.dart';

void main() {
  group('BulletList', () {
    testWidgets('renders list of strings with bullets', (tester) async {
      final items = ['Item 1', 'Item 2', 'Item 3'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BulletList(items: items),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
      expect(find.text('\u2022'), findsNWidgets(3));
    });
  });
}
