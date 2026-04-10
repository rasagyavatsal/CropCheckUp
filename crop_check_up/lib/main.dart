import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/camera_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait for a consistent camera experience.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Edge‑to‑edge system UI.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const CropCheckUpApp());
}

/// Root widget for CropCheckUp.
class CropCheckUpApp extends StatelessWidget {
  const CropCheckUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CropCheckUp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const CameraScreen(),
    );
  }
}
