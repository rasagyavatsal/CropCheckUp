import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/feedback/app_error_state.dart';

import 'package:crop_check_up/ui/theme/app_theme.dart';
import 'package:crop_check_up/ui/tokens/semantic_colors.dart';

void main() {
  group('AppErrorState', () {
    testWidgets('renders message and retry button correctly with proper tokens', (tester) async {
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
      
      final textFinder = find.text('Failed to load');
      expect(textFinder, findsOneWidget);
      
      final retryButton = find.text('Retry');
      expect(retryButton, findsOneWidget);
      
      await tester.tap(retryButton);
      expect(retryPressed, isTrue);

      final icon = tester.widget<Icon>(find.byType(Icon));
      final colors = AppTheme.light.extension<SemanticColors>()!;
      expect(icon.color, colors.danger);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.color, colors.danger);
      expect(textWidget.style?.fontSize, AppTheme.light.textTheme.bodyLarge?.fontSize);
    });
  });
}
