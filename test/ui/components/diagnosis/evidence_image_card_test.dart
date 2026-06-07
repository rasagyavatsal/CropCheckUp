import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/diagnosis/evidence_image_card.dart';
import 'package:crop_check_up/ui/components/images/app_image_panel.dart';
import '../../../support/test_image_fixtures.dart';

void main() {
  group('EvidenceImageCard', () {
    final mockBytes = transparentPngBytes;


    testWidgets('uses AppImagePanel with correct height', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EvidenceImageCard(
              imageBytes: mockBytes,
            ),
          ),
        ),
      );

      final appImagePanelFinder = find.byType(AppImagePanel);
      expect(appImagePanelFinder, findsOneWidget);

      final AppImagePanel panel = tester.widget(appImagePanelFinder);
      expect(panel.height, equals(220));
    });
  });
}
