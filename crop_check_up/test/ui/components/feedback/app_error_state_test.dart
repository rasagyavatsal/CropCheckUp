import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/feedback/app_error_state.dart';

import 'package:crop_check_up/ui/theme/app_theme.dart';

void main() {
  group('AppErrorState', () {
    testWidgets('renders message and retry button correctly', (tester) async {
      bool retryPressed = false;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppErrorState(
            message: 'Failed to load',
            onRetry: () => retryPressed = true,
          ),
        ),
      ));
      
      expect(find.text('Failed to load'), findsOneWidget);
      final retryButton = find.text('Retry');
      expect(retryButton, findsOneWidget);
      
      await tester.tap(retryButton);
      expect(retryPressed, isTrue);
    });
  });
}
