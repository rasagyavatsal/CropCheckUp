import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;


import '../services/plant_classifier.dart';
import '../theme/app_theme.dart';
import '../widgets/diagnosis_sheet.dart';
import 'camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _classifier = PlantClassifier();
  final _imagePicker = ImagePicker();
  
  bool _isInitialising = true;
  String? _initError;
  bool _isDiagnosing = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _isInitialising = true;
      _initError = null;
    });

    try {
      await _classifier.init();
    } catch (e) {
      _initError = e.toString();
    } finally {
      if (mounted) setState(() => _isInitialising = false);
    }
  }

  Future<void> _pickAndDiagnose() async {
    if (_isDiagnosing) return;

    final XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => _isDiagnosing = true);

    try {
      final bytes = await File(file.path).readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to decode image.')),
          );
        }
        return;
      }

      final result = _classifier.classifyImage(image);
      
      if (!mounted) return;
      
      if (result != null) {
        DiagnosisSheet.show(context, result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not confidently diagnose from this image.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDiagnosing = false);
      }
    }
  }

  @override
  void dispose() {
    _classifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialising) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppTheme.healthyGreen),
              SizedBox(height: 16),
              Text(
                'Loading AI model…',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_initError != null) {
      return Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppTheme.dangerRed),
                const SizedBox(height: 16),
                Text(
                  'Failed to load model',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _initError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white60),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _bootstrap,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CropCheckUp'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.eco_rounded,
                    size: 120,
                    color: AppTheme.healthyGreen,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to CropCheckUp',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Identify plant diseases instantly',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CameraScreen()),
                      );
                    },
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _pickAndDiagnose,
                    icon: const Icon(Icons.image_rounded),
                    label: const Text('Upload Image'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isDiagnosing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.healthyGreen),
                    SizedBox(height: 16),
                    Text(
                      'Analyzing Image...',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
