import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../services/camera_session.dart';

/// A dedicated viewfinder component that hides [CameraController] and [CameraPreview]
/// access from the UI, as required by the new architecture.
class AppCameraViewfinder extends StatefulWidget {
  final CameraSession session;
  final VoidCallback onResume;

  const AppCameraViewfinder({
    super.key,
    required this.session,
    required this.onResume,
  });

  @override
  State<AppCameraViewfinder> createState() => _AppCameraViewfinderState();
}

class _AppCameraViewfinderState extends State<AppCameraViewfinder>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.session.isRunning) return;
    if (state == AppLifecycleState.inactive) {
      widget.session.pause();
    } else if (state == AppLifecycleState.resumed) {
      widget.onResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.session.isRunning || widget.session.controller == null) {
      return const SizedBox.shrink();
    }
    return CameraPreview(widget.session.controller!);
  }
}
