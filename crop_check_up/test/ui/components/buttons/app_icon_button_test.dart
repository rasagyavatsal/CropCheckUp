import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/buttons/app_icon_button.dart';
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

  group('AppIconButton', () {
    testWidgets('renders icon and tooltip', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          AppIconButton(
            icon: Icons.camera_alt,
            tooltip: 'Camera',
            onPressed: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('responds to tap', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        buildTestableWidget(
          AppIconButton(
            icon: Icons.check,
            tooltip: 'Check',
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(AppIconButton));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('constructs and renders filled variant', (tester) async {
      await tester.pumpWidget(buildTestableWidget(AppIconButton.filled(
        icon: Icons.add,
        tooltip: 'Add',
        onPressed: () {},
      )));
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('constructs and renders translucent variant', (tester) async {
      await tester.pumpWidget(buildTestableWidget(AppIconButton.translucent(
        icon: Icons.close,
        tooltip: 'Close',
        onPressed: () {},
      )));
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('constructs and renders ghost variant', (tester) async {
      await tester.pumpWidget(buildTestableWidget(AppIconButton.ghost(
        icon: Icons.arrow_back,
        tooltip: 'Back',
        onPressed: () {},
      )));
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('constructs and renders danger variant', (tester) async {
      await tester.pumpWidget(buildTestableWidget(AppIconButton.danger(
        icon: Icons.delete,
        tooltip: 'Delete',
        onPressed: () {},
      )));
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });
  });
}
