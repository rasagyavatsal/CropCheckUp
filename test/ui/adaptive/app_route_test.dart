import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/adaptive/app_route.dart';

void main() {
  const testRoute = '/test';

  group('AppRoute', () {
    testWidgets('standard route creates a route that builds the page', (tester) async {
      final route = AppRoute.standard(builder: (context) => const Text('Standard Page'));
      
      await tester.pumpWidget(MaterialApp(
        onGenerateRoute: (settings) {
          if (settings.name == testRoute) {
            return route;
          }
          return null;
        },
        initialRoute: testRoute,
      ));

      expect(find.text('Standard Page'), findsOneWidget);
    });

    testWidgets('dialog route creates a fullscreen dialog route that builds the page', (tester) async {
      final route = AppRoute.dialog(builder: (context) => const Text('Dialog Page'));
      
      await tester.pumpWidget(MaterialApp(
        onGenerateRoute: (settings) {
          if (settings.name == testRoute) {
            return route;
          }
          return null;
        },
        initialRoute: testRoute,
      ));

      expect(find.text('Dialog Page'), findsOneWidget);
      expect((route as MaterialPageRoute).fullscreenDialog, isTrue);
    });
  });
}
