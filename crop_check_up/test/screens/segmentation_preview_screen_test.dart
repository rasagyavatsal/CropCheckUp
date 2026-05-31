import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/screens/segmentation_preview_screen.dart';

void main() {
  group('SegmentationPreviewScreen', () {
    // 1x1 transparent PNG
    final mockBytes = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
      0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
      0x42, 0x60, 0x82
    ]);

    testWidgets('renders image and action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SegmentationPreviewScreen(imageBytes: mockBytes),
        ),
      );

      // Check for title
      expect(find.text('Confirm Specimen'), findsOneWidget);
      
      // Check for buttons
      expect(find.widgetWithText(OutlinedButton, 'Retry'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Confirm'), findsOneWidget);
      
      // Check for Image.memory
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('Confirm button returns true', (WidgetTester tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await SegmentationPreviewScreen.show(context, mockBytes);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('Retry button returns false', (WidgetTester tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await SegmentationPreviewScreen.show(context, mockBytes);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });
  });
}
