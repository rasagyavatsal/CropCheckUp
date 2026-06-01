import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/app_design_system.dart';

void main() {
  testWidgets('AppDesignSystem barrel exports expected UI layers', (WidgetTester tester) async {
    // If these classes can be instantiated via the barrel file,
    // the structure and facade are correctly set up.
    expect(AppTokens(), isNotNull);
    expect(AppTheme.light, isNotNull);
    expect(AppAdaptive(), isNotNull);
    expect(AppComponents(), isNotNull);
  });
}
