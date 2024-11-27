// frontend/lib/presentation/widgets/common/common_button.dart

import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final ButtonStyle? style;

  const CommonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = backgroundColor ?? theme.colorScheme.primary;
    final buttonTextColor = textColor ?? theme.colorScheme.onPrimary;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style ??
            ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
        child: Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            color: buttonTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
