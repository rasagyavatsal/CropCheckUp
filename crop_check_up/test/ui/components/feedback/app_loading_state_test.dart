import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/feedback/app_loading_state.dart';

import 'package:crop_check_up/ui/theme/app_theme.dart';

void main() {
  group('AppLoadingState', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: AppLoadingState(message: 'Loading data...'))
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading data...'), findsOneWidget);
    });
  });
}
