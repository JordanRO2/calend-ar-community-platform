// common_section_title.dart
import 'package:flutter/material.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';
import 'package:frontend/presentation/widgets/common/common_responsive_breakpoints.dart';

class CommonSectionTitle extends StatelessWidget {
  final String title;
  final double? fontSize;
  final Color? titleColor;
  final VoidCallback? onTap;

  const CommonSectionTitle({
    super.key,
    this.title = AppTexts.sectionTitlePlaceholder,
    this.fontSize,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWeb = context.isWeb;
    final textColor = titleColor ?? theme.colorScheme.onSurface;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 24 : 16,
        vertical: isWeb ? 16 : 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: (isWeb
                      ? theme.textTheme.headlineSmall
                      : theme.textTheme.titleLarge)
                  ?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: fontSize,
              ),
            ),
          ),
          if (onTap != null)
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 16 : 12,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ver más',
                    style: (isWeb
                            ? theme.textTheme.titleMedium
                            : theme.textTheme.bodyLarge)
                        ?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: isWeb ? 18 : 14,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
