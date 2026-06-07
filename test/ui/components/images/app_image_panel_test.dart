import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/app_design_system.dart';
import '../../../support/test_image_fixtures.dart';

void main() {
  group('AppImagePanel', () {
    final mockBytes = transparentPngBytes;


    testWidgets('renders image with correct fit and semantic label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: AppImagePanel(
              imageBytes: mockBytes,
              semanticLabel: 'Test Image',
            ),
          ),
        ),
      );

      final semanticsFinder = find.bySemanticsLabel('Test Image');
      expect(semanticsFinder, findsOneWidget);

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final Image imageWidget = tester.widget(imageFinder);
      expect(imageWidget.fit, equals(BoxFit.contain));
    });
  });
}
