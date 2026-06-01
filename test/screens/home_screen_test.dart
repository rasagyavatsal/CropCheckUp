import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crop_check_up/screens/home_screen.dart';
import 'package:crop_check_up/ui/app_design_system.dart';
void main() {
  group('HomeScreen', () {
    testWidgets('renders AppLoadingState while initializing', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: const HomeScreen(),
      ));

      expect(find.byType(AppLoadingState), findsOneWidget);
    });
  });
}
