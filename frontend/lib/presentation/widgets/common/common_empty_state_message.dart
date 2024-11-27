// common_empty_state_message.dart
import 'package:flutter/material.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';
import 'package:frontend/presentation/widgets/common/common_responsive_breakpoints.dart';

class CommonEmptyStateMessage extends StatelessWidget {
  final String message;
  final IconData? icon;

  const CommonEmptyStateMessage({
    super.key,
    this.message = AppTexts.noEventsMessage,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWeb = context.isWeb;

    return SingleChildScrollView(
      // Añadido SingleChildScrollView
      child: Center(
        child: Padding(
          // Añadido Padding para evitar desbordamientos
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: isWeb ? 48 : 36,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                SizedBox(height: isWeb ? 16 : 12),
              ],
              Container(
                constraints: BoxConstraints(
                  maxWidth: isWeb ? 400 : 300,
                ),
                child: Text(
                  message,
                  style: (isWeb
                          ? theme.textTheme.titleMedium
                          : theme.textTheme.bodyMedium)
                      ?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
