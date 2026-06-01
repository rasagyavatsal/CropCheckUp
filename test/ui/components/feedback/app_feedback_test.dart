import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/components/feedback/app_feedback.dart';
import 'package:crop_check_up/ui/theme/app_theme.dart';

void main() {
  group('AppFeedback', () {
    testWidgets('shows success snackbar', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => AppFeedback.showSuccess(context, 'Success message'),
                child: const Text('Show'),
              );
            },
          ),
        ),
      ));
      
      await tester.tap(find.text('Show'));
      await tester.pump(); // Start animation
      
      expect(find.text('Success message'), findsOneWidget);
    });

    testWidgets('shows error snackbar', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => AppFeedback.showError(context, 'Error message'),
                child: const Text('Show'),
              );
            },
          ),
        ),
      ));
      
      await tester.tap(find.text('Show'));
      await tester.pump(); // Start animation
      
      expect(find.text('Error message'), findsOneWidget);
    });
  });
}
