import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_background_remover/image_background_remover.dart';

/// Pre-processes images by removing backgrounds for the plant classifier.
///
/// **Interface** (deep module):
///
///   • [init]              — load the ONNX background removal model.
///   • [processImageObj]   — removes background from an [img.Image].
///   • [processImageBytes] — removes background from raw encoded bytes (e.g. JPEG/PNG).
class BackgroundRemovalService {
  static final BackgroundRemovalService _instance = BackgroundRemovalService._internal();

  factory BackgroundRemovalService() => _instance;

  BackgroundRemovalService._internal();

  bool _isInit = false;

  Future<void> init() async {
    if (_isInit) return;
    await BackgroundRemover.instance.initializeOrt();
    _isInit = true;
  }

  /// Removes the background from a decoded image.
  Future<img.Image?> processImageObj(img.Image image) async {
    if (!_isInit) await init();
    // 1. Encode image to format acceptable by the remover (PNG).
    final bytes = await compute(img.encodePng, image);
    // 2. Remove background, getting PNG bytes with transparent bg.
    final resultBytes = await BackgroundRemover.instance.removeBgBytes(bytes);
    // 3. Decode back to an Image object.
    return compute(img.decodeImage, resultBytes);
  }

  /// Removes the background from raw encoded image bytes.
  Future<img.Image?> processImageBytes(Uint8List bytes) async {
    if (!_isInit) await init();
    // 1. Remove background, getting PNG bytes with transparent bg.
    final resultBytes = await BackgroundRemover.instance.removeBgBytes(bytes);
    // 2. Decode back to an Image object.
    return compute(img.decodeImage, resultBytes);
  }
}
