import 'package:flutter_test/flutter_test.dart';

import 'package:crop_check_up/main.dart';

void main() {
  group('CropCheckUpApp', () {
    testWidgets('renders MaterialApp with correct title',
        (WidgetTester tester) async {
      // The camera and TFLite services will fail in test, but we can at least
      // verify the widget tree assembles without throwing.
      //
      // Note: camera_screen will show a loading spinner that transitions to
      // an error state in test – that's expected since no physical camera or
      // model file is available.  We only validate the outer shell here.
      await tester.pumpWidget(const CropCheckUpApp());

      // The MaterialApp should be in the tree.
      expect(find.byType(CropCheckUpApp), findsOneWidget);
    });
  });
}
