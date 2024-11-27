// lib/presentation/widgets/register_screen/register_actions.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/common/common_button.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';
import 'package:go_router/go_router.dart';

class RegisterActions extends StatelessWidget {
  final VoidCallback onRegisterPressed;

  const RegisterActions({
    super.key,
    required this.onRegisterPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        CommonButton(
          text: AppTexts.registerButton,
          onPressed: onRegisterPressed,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppTexts.alreadyHaveAccount,
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
