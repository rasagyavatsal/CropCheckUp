import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/tokens/semantic_colors.dart';
import 'package:crop_check_up/ui/theme/app_layout_theme.dart';
import 'package:crop_check_up/ui/theme/camera_theme.dart';
import 'package:crop_check_up/ui/theme/diagnosis_status_theme.dart';

extension AppThemeExtension on BuildContext {
  SemanticColors get appColors => Theme.of(this).extension<SemanticColors>()!;
  AppLayoutTheme get appLayout => Theme.of(this).extension<AppLayoutTheme>()!;
  CameraTheme get cameraTokens => Theme.of(this).extension<CameraTheme>()!;
  DiagnosisStatusTheme get diagnosisStatus => Theme.of(this).extension<DiagnosisStatusTheme>()!;
}
