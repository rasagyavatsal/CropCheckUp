import 'package:flutter/material.dart';
import 'package:crop_check_up/ui/theme/theme_ext.dart';
import 'package:crop_check_up/ui/tokens/spacing_tokens.dart';
import 'package:crop_check_up/ui/tokens/typography.dart';

class BulletList extends StatelessWidget {
  final List<String> items;

  const BulletList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    const spacing = SpacingTokens();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: EdgeInsets.only(bottom: spacing.m),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\u2022',
                style: context.typography.body.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colors.brand,
                  fontSize: 18,
                ),
              ),
              SizedBox(width: spacing.m),
              Expanded(
                child: Text(
                  item,
                  style: context.typography.body.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
