import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/layout/app_page_shell.dart';
import 'package:crop_check_up/ui/components/layout/app_scroll_wrapper.dart';
import 'package:crop_check_up/ui/components/layout/app_safe_area.dart';

void main() {
  group('AppPageShell', () {
    testWidgets('basic usage wraps in Scaffold and AppSafeArea', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppPageShell(
            appBar: AppBar(title: const Text('Title')),
            child: const SizedBox(key: Key('child')),
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppSafeArea), findsOneWidget);
      expect(find.byKey(const Key('child')), findsOneWidget);
    });

    testWidgets('scrollable factory uses AppScrollWrapper', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppPageShell.scrollable(
            child: const SizedBox(key: Key('child')),
          ),
        ),
      );

      expect(find.byType(AppScrollWrapper), findsOneWidget);
    });

    testWidgets('sliver factory uses CustomScrollView', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppPageShell.sliver(
            slivers: const [
              SliverToBoxAdapter(child: SizedBox(key: Key('child'))),
            ],
          ),
        ),
      );

      expect(find.byType(CustomScrollView), findsOneWidget);
    });
  });
}
