import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/screens/segmentation_preview_screen.dart';
import 'package:crop_check_up/ui/app_design_system.dart';
import '../support/test_image_fixtures.dart';

void main() {
  group('SegmentationPreviewScreen', () {
    // 1x1 transparent PNG
    final mockBytes = transparentPngBytes;

    Future<void> pumpPreviewHelper(
      WidgetTester tester, {
      required void Function(bool?) onResult,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Builder(
            builder:
                (context) => ElevatedButton(
                  onPressed: () async {
                    final result = await SegmentationPreviewScreen.show(
                      context,
                      mockBytes,
                    );
                    onResult(result);
                  },
                  child: const Text('Open'),
                ),
          ),
        ),
      );
    }

    Future<void> tapConfirm(WidgetTester tester) async {
      await tester.tap(find.text('Diagnose'));
      await tester.pumpAndSettle();
    }

    Future<void> tapRetry(WidgetTester tester) async {
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders image and action buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: SegmentationPreviewScreen(imageBytes: mockBytes),
        ),
      );

      // Check for title
      expect(find.text('Review Leaf'), findsOneWidget);

      // Check for buttons
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Diagnose'), findsOneWidget);

      // Check for Image inside Card
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('Diagnose button returns true', (WidgetTester tester) async {
      bool? result;
      await pumpPreviewHelper(
        tester,
        onResult: (r) => result = r,
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tapConfirm(tester);

      expect(result, isTrue);
    });

    testWidgets('Try Again button returns false', (WidgetTester tester) async {
      bool? result;
      await pumpPreviewHelper(
        tester,
        onResult: (r) => result = r,
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tapRetry(tester);

      expect(result, isFalse);
    });
  });
}
