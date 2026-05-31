import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crop_check_up/ui/theme/app_theme.dart';
import 'package:crop_check_up/ui/theme/theme_ext.dart';
import 'package:crop_check_up/ui/theme/app_layout_theme.dart';
import 'package:crop_check_up/ui/theme/camera_theme.dart';
import 'package:crop_check_up/ui/theme/diagnosis_status_theme.dart';
import 'package:crop_check_up/ui/tokens/semantic_colors.dart';

void main() {
  testWidgets('BuildContext provides appColors, appLayout, cameraTokens, and diagnosisStatus', (WidgetTester tester) async {
    late SemanticColors retrievedColors;
    late AppLayoutTheme retrievedLayout;
    late CameraTheme retrievedCamera;
    late DiagnosisStatusTheme retrievedDiagnosis;
    
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) {
            retrievedColors = context.appColors;
            retrievedLayout = context.appLayout;
            retrievedCamera = context.cameraTokens;
            retrievedDiagnosis = context.diagnosisStatus;
            return const SizedBox();
          },
        ),
      ),
    );
    
    expect(retrievedColors, isNotNull);
    expect(retrievedLayout, isNotNull);
    expect(retrievedCamera, isNotNull);
    expect(retrievedDiagnosis, isNotNull);
    
    expect(retrievedCamera.scrim, isNotNull);
    expect(retrievedCamera.frameRatio, isNotNull);
    
    expect(retrievedDiagnosis.healthyColor, equals(SemanticColors.light.success));
  });
}
