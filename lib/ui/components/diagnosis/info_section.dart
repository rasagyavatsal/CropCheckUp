import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/theme/theme_ext.dart';
import 'package:crop_check_up/ui/tokens/radius_tokens.dart';
import 'package:crop_check_up/ui/tokens/spacing_tokens.dart';
import 'package:crop_check_up/ui/tokens/typography.dart';

class InfoSection extends StatelessWidget {
  final String title;
  final Widget content;
  final IconData? icon;

  const InfoSection({
    super.key,
    required this.title,
    required this.content,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    const radius = RadiusTokens();
    const spacing = SpacingTokens();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.l),
      decoration: BoxDecoration(
        color: colors.raisedSurface,
        borderRadius: BorderRadius.circular(radius.l),
        border: Border.all(color: colors.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.brand.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(radius.l),
                  ),
                  child: Icon(icon, size: 20, color: colors.brand),
                ),
                SizedBox(width: spacing.m),
              ],
              Expanded(
                child: Text(
                  title,
                  style: context.typography.title.copyWith(
                    color: colors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.m),
          content,
        ],
      ),
    );
  }
}
