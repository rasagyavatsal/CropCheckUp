import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/cards/app_card.dart';
import 'package:crop_check_up/ui/theme/app_theme.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );
  }

  group('AppCard', () {
    testWidgets('renders base card with content', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppCard(
            child: Text('Base Card Content'),
          ),
        ),
      );

      expect(find.text('Base Card Content'), findsOneWidget);
    });

    testWidgets('AppCard.action supports tap handler', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          AppCard.action(
            onTap: () => tapped = true,
            child: const Text('Action Card Content'),
          ),
        ),
      );

      await tester.tap(find.text('Action Card Content'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('AppCard.info renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppCard.info(
            child: Text('Info Card Content'),
          ),
        ),
      );

      expect(find.text('Info Card Content'), findsOneWidget);
    });

    testWidgets('AppCard.status renders with title, subtitle, and icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppCard.status(
            title: 'Status Title',
            subtitle: 'Status Subtitle',
            icon: Icons.check_circle,
            statusColor: Colors.green,
          ),
        ),
      );

      expect(find.text('Status Title'), findsOneWidget);
      expect(find.text('Status Subtitle'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('AppCard.image renders with clipped image', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          AppCard.image(
            image: Container(
              key: const Key('image_content'),
              color: Colors.red,
            ),
            child: const Text('Image Card Label'),
          ),
        ),
      );

      expect(find.byKey(const Key('image_content')), findsOneWidget);
      expect(find.text('Image Card Label'), findsOneWidget);
    });

    testWidgets('AppCard.elevated renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const AppCard.elevated(
            child: Text('Elevated Card Content'),
          ),
        ),
      );

      expect(find.text('Elevated Card Content'), findsOneWidget);
    });
  });
}
