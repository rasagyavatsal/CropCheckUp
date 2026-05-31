import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/diagnosis/info_section.dart';

void main() {
  group('InfoSection', () {
    testWidgets('renders title and content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InfoSection(
              title: 'Symptoms',
              content: Text('Yellow leaves'),
              icon: Icons.info,
            ),
          ),
        ),
      );

      expect(find.text('Symptoms'), findsOneWidget);
      expect(find.text('Yellow leaves'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });
  });
}
