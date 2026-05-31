import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/tokens/typography.dart';
import 'package:crop_check_up/ui/theme/theme_ext.dart';
import 'package:crop_check_up/ui/tokens/gradient_tokens.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final List<Widget>? actions;

  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    return AppBar(
      leading: leading,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(title, style: typography.title),
            ],
          ),
          if (subtitle != null)
            Text(subtitle!, style: typography.caption),
        ],
      ),
      actions: actions,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AppSliverHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final Gradient? backgroundGradient;
  final List<Widget>? actions;
  final double expandedHeight;

  const AppSliverHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.backgroundGradient,
    this.actions,
    this.expandedHeight = 200.0, // Should be tokenized eventually
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final colors = context.appColors;
    
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      leading: leading,
      actions: actions,
      backgroundColor: colors.surface,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        centerTitle: false,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: colors.textPrimary),
                  const SizedBox(width: 4),
                ],
                Text(
                  title,
                  style: typography.title.copyWith(color: colors.textPrimary),
                ),
              ],
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: typography.caption.copyWith(color: colors.textPrimary.withValues(alpha: 0.7)),
              ),
          ],
        ),
        background: backgroundGradient != null
            ? Container(
                decoration: BoxDecoration(
                  gradient: backgroundGradient,
                ),
              )
            : null,
      ),
    );
  }
}

class AppBrandHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const AppBrandHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final gradients = Theme.of(context).extension<GradientTokens>()!;
    return AppSliverHeader(
      title: title,
      subtitle: subtitle,
      backgroundGradient: gradients.brandHeader,
      expandedHeight: 180.0,
    );
  }
}

class AppStatusHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData statusIcon;
  final bool isHealthy;

  const AppStatusHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.statusIcon,
    this.isHealthy = true,
  });

  @override
  Widget build(BuildContext context) {
    final gradients = Theme.of(context).extension<GradientTokens>()!;
    return AppSliverHeader(
      title: title,
      subtitle: subtitle,
      icon: statusIcon,
      backgroundGradient: isHealthy ? gradients.healthyStatus : gradients.dangerStatus,
      expandedHeight: 240.0,
    );
  }
}
