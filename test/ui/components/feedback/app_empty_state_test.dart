import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/feedback/app_empty_state.dart';

import 'package:crop_check_up/ui/theme/app_theme.dart';
import 'package:crop_check_up/ui/tokens/semantic_colors.dart';

void main() {
  group('AppEmptyState', () {
    testWidgets('renders message and optional action with proper tokens', (tester) async {
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
      
      final textFinder = find.text('No data found');
      expect(textFinder, findsOneWidget);
      
      final actionButton = find.text('Add Data');
      expect(actionButton, findsOneWidget);
      
      await tester.tap(actionButton);
      expect(actionPressed, isTrue);

      final icon = tester.widget<Icon>(find.byType(Icon));
      final colors = AppTheme.light.extension<SemanticColors>()!;
      expect(icon.color, colors.mutedText);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.color, colors.mutedText);
      expect(textWidget.style?.fontSize, AppTheme.light.textTheme.bodyLarge?.fontSize);
    });
  });
}
