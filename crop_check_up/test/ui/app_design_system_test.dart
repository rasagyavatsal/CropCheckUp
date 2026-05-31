import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/app_design_system.dart';

void main() {
  test('AppDesignSystem barrel exports expected UI layers', () {
    // If these classes can be instantiated via the barrel file,
    // the structure and facade are correctly set up.
    expect(AppTokens(), isNotNull);
    expect(AppTheme(), isNotNull);
    expect(AppAdaptive(), isNotNull);
    expect(AppComponents(), isNotNull);
  });
}
