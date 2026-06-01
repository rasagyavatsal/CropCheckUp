import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/headers/app_headers.dart';
import 'package:crop_check_up/ui/theme/app_theme.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: child,
    );
  }

  group('AppTopBar', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const Scaffold(
            appBar: AppTopBar(
              title: 'My Title',
              subtitle: 'My Subtitle',
              icon: Icons.ac_unit,
            ),
          ),
        ),
      );

      expect(find.text('My Title'), findsOneWidget);
      expect(find.text('My Subtitle'), findsOneWidget);
      expect(find.byIcon(Icons.ac_unit), findsOneWidget);
    });
  });

  group('AppSliverHeader', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const Scaffold(
            body: CustomScrollView(
              slivers: [
                AppSliverHeader(
                  title: 'Sliver Title',
                  subtitle: 'Sliver Sub',
                  icon: Icons.eco,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Sliver Title'), findsOneWidget);
      expect(find.text('Sliver Sub'), findsOneWidget);
      expect(find.byIcon(Icons.eco), findsOneWidget);
    });
  });

  group('AppBrandHeader', () {
    testWidgets('renders with correct properties', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const Scaffold(
            body: CustomScrollView(
              slivers: [
                AppBrandHeader(
                  title: 'Brand Title',
                  subtitle: 'Brand Sub',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Brand Title'), findsOneWidget);
      expect(find.text('Brand Sub'), findsOneWidget);
      
      final sliverHeader = tester.widget<AppSliverHeader>(find.byType(AppSliverHeader));
      expect(sliverHeader.backgroundGradient, isNotNull);
      expect(sliverHeader.expandedHeight, 180.0);
    });
  });

  group('AppStatusHeader', () {
    testWidgets('renders healthy state', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const Scaffold(
            body: CustomScrollView(
              slivers: [
                AppStatusHeader(
                  title: 'Healthy Plant',
                  statusIcon: Icons.check_circle,
                  isHealthy: true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Healthy Plant'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      final sliverHeader = tester.widget<AppSliverHeader>(find.byType(AppSliverHeader));
      expect(sliverHeader.backgroundGradient, isNotNull);
      expect(sliverHeader.expandedHeight, 240.0);
    });
  });
}
