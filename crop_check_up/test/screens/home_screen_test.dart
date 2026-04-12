import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crop_check_up/screens/home_screen.dart';

void main() {
  group('HomeScreen Widgets', () {
    testWidgets('renders initial UI shell without throwing', (WidgetTester tester) async {
      // We only validate the outer shell here, as PlantClassifier loads TFLite models
      // which will fail outside of an emulator/device. It will present the error UI eventually.
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      
      // Wait for initialization to happen and eventually trigger error or completion state.
      await tester.pumpAndSettle();

      // Check that at least some core framework layers exist
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
