import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/main.dart';
import 'package:crop_check_up/ui/app_design_system.dart';

void main() {
  testWidgets('CropCheckUpApp configures theme and scroll behavior', (tester) async {
    await tester.pumpWidget(const CropCheckUpApp());

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(materialApp.themeMode, ThemeMode.system);
    expect(materialApp.theme?.brightness, AppTheme.light.brightness);
    expect(materialApp.darkTheme?.brightness, AppTheme.dark.brightness);
    expect(materialApp.scrollBehavior, isA<AppScrollBehavior>());
  });
}
