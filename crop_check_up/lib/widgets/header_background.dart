import 'package:flutter/material.dart';
import '../ui/tokens/typography.dart';
import '../theme/app_theme.dart';

class HeaderBackground extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const HeaderBackground({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), AppTheme.healthyGreen],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              icon ?? Icons.eco_rounded,
              size: 140,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Center(
            child: Opacity(
              opacity: 0.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon ?? Icons.eco_rounded, size: 32, color: Colors.white),
                  const SizedBox(height: 4),
                  Text(
                    subtitle ?? 'PROTECT YOUR HARVEST',
                    style: context.typography.overline.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 20), // Space for the title
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
