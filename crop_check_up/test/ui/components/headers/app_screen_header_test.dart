import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/headers/app_headers.dart';
import 'package:crop_check_up/ui/theme/app_theme.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('AppScreenHeader', () {
    testWidgets('renders brand title with icon and trailing action', (WidgetTester tester) async {
      bool actionTapped = false;
      
      await tester.pumpWidget(buildTestableWidget(
        AppScreenHeader(
          title: 'CropCheckUp',
          brandMark: const Icon(Icons.eco_rounded),
          centerTitle: false,
          trailing: IconButton(
            icon: const Icon(Icons.dark_mode_rounded),
            onPressed: () => actionTapped = true,
          ),
        ),
      ));

      expect(find.text('CropCheckUp'), findsOneWidget);
      expect(find.byIcon(Icons.eco_rounded), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.dark_mode_rounded));
      expect(actionTapped, isTrue);
    });
  });
}
