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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
