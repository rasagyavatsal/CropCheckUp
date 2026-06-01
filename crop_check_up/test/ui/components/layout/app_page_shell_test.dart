import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/layout/app_page_shell.dart';
import 'package:crop_check_up/ui/components/layout/app_scroll_wrapper.dart';
import 'package:crop_check_up/ui/theme/app_theme.dart';
import 'package:crop_check_up/ui/theme/theme_ext.dart';

void main() {
  group('AppPageShell', () {
    testWidgets('uses appColors.background by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const AppPageShell(
            child: SizedBox(),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      final BuildContext context = tester.element(find.byType(AppPageShell));
      
      expect(scaffold.backgroundColor, context.appColors.background);
    });
    testWidgets('basic usage wraps in Scaffold and AppSafeArea', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: AppPageShell(
            appBar: AppBar(title: const Text('Title')),
            child: const SizedBox(key: Key('child')),
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsWidgets);
      expect(find.byKey(const Key('child')), findsOneWidget);
    });

    testWidgets('scrollable factory uses AppScrollWrapper', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
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
          theme: AppTheme.light,
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
