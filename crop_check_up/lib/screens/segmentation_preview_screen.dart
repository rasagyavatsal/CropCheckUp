import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../ui/tokens/typography.dart';
import '../ui/tokens/app_tokens.dart';
import '../ui/app_design_system.dart';

/// Screen to preview the segmented image before inference.
/// 
/// This allows the user to verify if the background removal was successful 
/// and if the leaf is clearly visible.
class SegmentationPreviewScreen extends StatelessWidget {
  final Uint8List imageBytes;

  const SegmentationPreviewScreen({
    super.key,
    required this.imageBytes,
  });

  /// Shows the preview screen and returns true if confirmed, false if retried.
  static Future<bool?> show(BuildContext context, Uint8List imageBytes) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SegmentationPreviewScreen(imageBytes: imageBytes),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Subtle gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: context.gradient.previewBackdrop,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),
                
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        'Confirm Specimen',
                        style: context.typography.headline.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Is the background removal correct? Ensure only the plant leaf is clearly visible.',
                        style: context.typography.label.copyWith(
                          color: Colors.white70,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Image Preview
                Expanded(
                  child: Center(
                    child: Hero(
                      tag: 'segmentation_preview',
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                              blurRadius: 50,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white10,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.memory(
                            imageBytes,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Action Buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Row(
                    children: [
                      // Retry Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.refresh_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Retry',
                                style: context.typography.button.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Confirm Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 8,
                            shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Confirm',
                                style: context.typography.button.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
