import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/images/app_brand_mark.dart';

void main() {
  group('AppBrandMark', () {
    testWidgets('renders logo asset with correct default size', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: AppBrandMark(),
        ),
      ));

      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName, 'assets/logo.png');
      expect(image.width, 28.0);
      expect(image.height, 28.0);
    });

    testWidgets('respects custom size', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: AppBrandMark(size: 48.0),
        ),
      ));

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.width, 48.0);
      expect(image.height, 48.0);
    });
  });
}
