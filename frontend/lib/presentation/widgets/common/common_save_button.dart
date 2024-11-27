// frontend/lib/presentation/widgets/common/common_save_button.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';

class CommonSaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const CommonSaveButton({
    super.key,
    required this.onPressed,
    this.text = AppTexts.saveChanges,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        child: Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
