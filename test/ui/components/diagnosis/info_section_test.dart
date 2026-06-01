import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/diagnosis/info_section.dart';
import 'package:crop_check_up/ui/theme/app_theme.dart';

void main() {
  group('InfoSection', () {
    testWidgets('renders title and content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
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
