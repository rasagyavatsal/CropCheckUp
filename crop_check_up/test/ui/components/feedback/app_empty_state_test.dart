import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/feedback/app_empty_state.dart';

import 'package:crop_check_up/ui/theme/app_theme.dart';

void main() {
  group('AppEmptyState', () {
    testWidgets('renders message and optional action', (tester) async {
      bool actionPressed = false;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppEmptyState(
            message: 'No data found',
            actionLabel: 'Add Data',
            onAction: () => actionPressed = true,
          ),
        ),
      ));
      
      expect(find.text('No data found'), findsOneWidget);
      final actionButton = find.text('Add Data');
      expect(actionButton, findsOneWidget);
      
      await tester.tap(actionButton);
      expect(actionPressed, isTrue);
    });
  });
}
