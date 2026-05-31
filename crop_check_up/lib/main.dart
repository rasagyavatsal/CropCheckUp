import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';
import 'ui/app_design_system.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait for a consistent camera experience.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Edge-to-edge system UI.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

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
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      scrollBehavior: const AppScrollBehavior(),
      home: const HomeScreen(),
    );
  }
}
