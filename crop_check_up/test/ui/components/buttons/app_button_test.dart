import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/buttons/app_button.dart';
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

  group('AppButton.primary', () {
    testWidgets('renders label and responds to tap', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        buildTestableWidget(
          AppButton.primary(
            label: 'Primary Button',
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      );

      expect(find.text('Primary Button'), findsOneWidget);

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });
    testWidgets('respects disabled state', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        buildTestableWidget(
          AppButton.primary(
            label: 'Primary Button',
            onPressed: null,
          ),
        ),
      );

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(pressed, isFalse);
    });

    testWidgets('shows progress indicator and ignores tap when isLoading', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        buildTestableWidget(
          AppButton.primary(
            label: 'Primary Button',
            isLoading: true,
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(pressed, isFalse);
    });
  });

  group('AppButton Variants', () {
    testWidgets('constructs and renders secondary variant', (tester) async {
      await tester.pumpWidget(buildTestableWidget(AppButton.secondary(label: 'Secondary', onPressed: () {})));
      expect(find.text('Secondary'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('constructs and renders tonal variant', (tester) async {
      await tester.pumpWidget(buildTestableWidget(AppButton.tonal(label: 'Tonal', onPressed: () {})));
      expect(find.text('Tonal'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('constructs and renders ghost variant', (tester) async {
      await tester.pumpWidget(buildTestableWidget(AppButton.ghost(label: 'Ghost', onPressed: () {})));
      expect(find.text('Ghost'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('constructs and renders danger variant', (tester) async {
      await tester.pumpWidget(buildTestableWidget(AppButton.danger(label: 'Danger', onPressed: () {})));
      expect(find.text('Danger'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('constructs and renders outlined variant', (tester) async {
      await tester.pumpWidget(buildTestableWidget(AppButton.outlined(label: 'Outlined', onPressed: () {})));
      expect(find.text('Outlined'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(buildTestableWidget(AppButton.primary(
        label: 'With Icon',
        icon: Icons.check,
        onPressed: () {},
      )));
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
    });

    testWidgets('expands to full width when isFullWidth is true', (tester) async {
      await tester.pumpWidget(buildTestableWidget(AppButton.primary(
        label: 'Full Width',
        isFullWidth: true,
        onPressed: () {},
      )));
      
      final sizedBoxFinder = find.ancestor(
        of: find.byType(ElevatedButton),
        matching: find.byType(SizedBox),
      ).first;
      
      final SizedBox sizedBox = tester.widget(sizedBoxFinder);
      expect(sizedBox.width, double.infinity);
    });
  });
}
