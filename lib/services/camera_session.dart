import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Manages a single device camera, exposing a decoded image stream.
///
/// **Interface** (deep module):
///
///   • [start]        — initialise and begin streaming frames.
///   • [stop]         — release the camera.
///   • [toggleFlash]  — cycle flash on / off.
///   • [captureFrame] — grab the latest decoded frame on demand.
///   • [controller]   — raw [CameraController] for the preview widget.
///
/// All resolution negotiation, format conversion (platform‑specific YUV → RGB),
/// lifecycle management and error recovery are hidden.
class CameraSession {
  CameraController? _controller;
  img.Image? _latestFrame;
  bool _isFlashOn = false;
  bool _isProcessingFrame = false;

  /// The underlying controller – needed by [CameraPreview] in the UI layer.
  CameraController? get controller => _controller;

  /// Whether the camera is initialised and streaming.
  bool get isRunning => _controller?.value.isInitialized ?? false;

  /// Current flash state.
  bool get isFlashOn => _isFlashOn;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Initialise the rear camera and start the image stream.
  Future<void> start() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw StateError('No cameras available on this device');
    }

    // Prefer the rear camera.
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _controller!.initialize();
    await _controller!.setFocusMode(FocusMode.auto);
    await _controller!.setFlashMode(FlashMode.off);

    _controller!.startImageStream(_onFrame);
  }

  /// Stop streaming and release the camera.
  Future<void> stop() async {
    if (_controller == null) return;
    if (_controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
    }
    await _controller!.dispose();
    _controller = null;
    _latestFrame = null;
  }

  /// Pause the camera session.
  Future<void> pause() async {
    await stop();
  }

  /// Resume the camera session.
  Future<void> resume() async {
    await start();
  }

  /// Toggle the torch / flash LED.
  Future<void> toggleFlash() async {
    if (_controller == null) return;
    _isFlashOn = !_isFlashOn;
    await _controller!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
  }

  /// Returns the most recently decoded camera frame, or `null`.
  img.Image? captureFrame() => _latestFrame;

  // ---------------------------------------------------------------------------
  // Private implementation
  // ---------------------------------------------------------------------------

  /// Decode one camera frame, throttled so at most one decode runs at a time.
  void _onFrame(CameraImage frame) {
    if (_isProcessingFrame) return;
    _isProcessingFrame = true;

    // Run YUV→RGB conversion off the UI thread via compute().
    compute(_decodeYuv420, _CameraFrameMessage.fromCameraImage(frame))
        .then((decoded) {
      _latestFrame = decoded;
      _isProcessingFrame = false;
    }).catchError((_) {
      _isProcessingFrame = false;
    });
  }

  /// Top‑level function suitable for [compute] — converts YUV420 planes to
  /// an [img.Image].
  static img.Image _decodeYuv420(_CameraFrameMessage msg) {
    final image = img.Image(width: msg.width, height: msg.height);

    for (int y = 0; y < msg.height; y++) {
      for (int x = 0; x < msg.width; x++) {
        final yIndex = y * msg.yRowStride + x;
        final uvIndex = (y >> 1) * msg.uvRowStride + (x & ~1);

        final yVal = msg.yPlane[yIndex];
        final uVal = msg.uPlane[uvIndex];
        final vVal = msg.vPlane[uvIndex];

        final r = (yVal + 1.370705 * (vVal - 128)).clamp(0, 255).toInt();
        final g = (yVal - 0.337633 * (uVal - 128) - 0.698001 * (vVal - 128))
            .clamp(0, 255)
            .toInt();
        final b = (yVal + 1.732446 * (uVal - 128)).clamp(0, 255).toInt();

        image.setPixelRgb(x, y, r, g, b);
      }
    }
    return image;
  }
}

/// Serialisable message for [compute] – [CameraImage] itself is not sendable
/// across isolates, so we extract the raw byte planes.
class _CameraFrameMessage {
  final int width;
  final int height;
  final Uint8List yPlane;
  final Uint8List uPlane;
  final Uint8List vPlane;
  final int yRowStride;
  final int uvRowStride;

  const _CameraFrameMessage({
    required this.width,
    required this.height,
    required this.yPlane,
    required this.uPlane,
    required this.vPlane,
    required this.yRowStride,
    required this.uvRowStride,
  });

  factory _CameraFrameMessage.fromCameraImage(CameraImage image) {
    return _CameraFrameMessage(
      width: image.width,
      height: image.height,
      yPlane: Uint8List.fromList(image.planes[0].bytes),
      uPlane: Uint8List.fromList(image.planes[1].bytes),
      vPlane: Uint8List.fromList(image.planes[2].bytes),
      yRowStride: image.planes[0].bytesPerRow,
      uvRowStride: image.planes[1].bytesPerRow,
    );
  }
}
