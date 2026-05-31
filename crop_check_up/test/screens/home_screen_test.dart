import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crop_check_up/screens/home_screen.dart';
import 'package:crop_check_up/theme/app_theme.dart';

void main() {
  group('HomeScreen Widgets', () {
    testWidgets('renders initial UI shell without throwing', (WidgetTester tester) async {
      // We only validate the outer shell here, as PlantClassifier loads TFLite models
      // which will fail outside of an emulator/device. It will present the error UI eventually.
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ));
      
      // We use pump with a duration instead of pumpAndSettle because native plugin 
      // initialization (TFLite/ONNX) might block endlessly in a test environment.
      await tester.pump(const Duration(seconds: 2));

      // Check that at least some core framework layers exist
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
