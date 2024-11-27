// lib/presentation/widgets/forgot_password_screen/forgot_password_actions.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/common/common_button.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordActions extends StatelessWidget {
  final VoidCallback onResetPressed;

  const ForgotPasswordActions({
    super.key,
    required this.onResetPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        CommonButton(
          text: AppTexts.resetPasswordButton,
          onPressed: onResetPressed,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "¿Recordaste tu contraseña?",
              style: theme.textTheme.bodyMedium,
            ),
            TextButton(
              onPressed: () {
                context.go('/login');
              },
              child: Text(
                AppTexts.loginButton,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
