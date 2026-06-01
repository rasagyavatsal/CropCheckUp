import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/theme/theme_ext.dart';

class AppProcessingOverlay extends StatelessWidget {
  final String message;

  const AppProcessingOverlay({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    
    return AbsorbPointer(
      absorbing: true,
      child: Container(
        color: colors.cameraScrim,
        alignment: Alignment.center,
        child: Semantics(
          liveRegion: true,
          child: CircularProgressIndicator(
            semanticsLabel: message,
          ),
        ),
      ),
    );
  }
}
