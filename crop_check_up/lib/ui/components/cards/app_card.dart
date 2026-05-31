import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/tokens/semantic_colors.dart';
import 'package:crop_check_up/ui/tokens/spacing_tokens.dart';
import 'package:crop_check_up/ui/tokens/radius_tokens.dart';
import 'package:crop_check_up/ui/tokens/elevation_tokens.dart';

enum _CardVariant { base, action, info, status, image, elevated }

class AppCard extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onTap;
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Color? statusColor;
  final Widget? image;
  final _CardVariant _variant;

  const AppCard({
    super.key,
    this.child,
  })  : _variant = _CardVariant.base,
        onTap = null,
        title = null,
        subtitle = null,
        icon = null,
        statusColor = null,
        image = null;

  const AppCard.action({
    super.key,
    this.child,
    this.onTap,
  })  : _variant = _CardVariant.action,
        title = null,
        subtitle = null,
        icon = null,
        statusColor = null,
        image = null;

  const AppCard.info({
    super.key,
    this.child,
  })  : _variant = _CardVariant.info,
        onTap = null,
        title = null,
        subtitle = null,
        icon = null,
        statusColor = null,
        image = null;

  const AppCard.status({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.statusColor,
  })  : _variant = _CardVariant.status,
        child = null,
        onTap = null,
        image = null;

  const AppCard.image({
    super.key,
    required this.image,
    this.child,
    this.onTap,
  })  : _variant = _CardVariant.image,
        title = null,
        subtitle = null,
        icon = null,
        statusColor = null;

  const AppCard.elevated({
    super.key,
    this.child,
  })  : _variant = _CardVariant.elevated,
        onTap = null,
        title = null,
        subtitle = null,
        icon = null,
        statusColor = null,
        image = null;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<SemanticColors>();
    const spacing = SpacingTokens();
    const radius = RadiusTokens();
    
    Color? backgroundColor;
    double? elevation;
    BorderSide? borderSide;

    switch (_variant) {
      case _CardVariant.base:
        break;
      case _CardVariant.image:
        break;
      case _CardVariant.action:
        backgroundColor = tokens?.surface;
        break;
      case _CardVariant.info:
        backgroundColor = tokens?.raisedSurface;
        break;
      case _CardVariant.elevated:
        elevation = ElevationTokens.medium;
        backgroundColor = tokens?.surface;
        break;
      case _CardVariant.status:
        backgroundColor = tokens?.surface;
        if (statusColor != null) {
          borderSide = BorderSide(color: statusColor!, width: 2.0);
        }
        break;
    }

    Widget cardContent = _buildContent(context, tokens, spacing);

    return Card(
      elevation: elevation,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius.l),
        side: borderSide ?? BorderSide.none,
      ),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              child: cardContent,
            )
          : cardContent,
    );
  }

  Widget _buildContent(BuildContext context, SemanticColors? tokens, SpacingTokens spacing) {
    if (_variant == _CardVariant.status) {
      return Padding(
        padding: EdgeInsets.all(spacing.m),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: statusColor ?? tokens?.textPrimary),
              SizedBox(width: spacing.m),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    Text(title!, style: Theme.of(context).textTheme.titleMedium),
                  if (subtitle != null)
                    Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: tokens?.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    if (_variant == _CardVariant.image) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (image != null) image!,
          if (child != null)
            Padding(
              padding: EdgeInsets.all(spacing.m),
              child: child!,
            ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.all(spacing.m),
      child: child ?? const SizedBox.shrink(),
    );
  }
}
