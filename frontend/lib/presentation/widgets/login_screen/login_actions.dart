// lib/presentation/widgets/login_screen/login_actions.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/common/common_button.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';
import 'package:go_router/go_router.dart';

class LoginActions extends StatelessWidget {
  final bool rememberMe;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onLoginPressed;

  const LoginActions({
    super.key,
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        // Remember me switch
        Row(
          children: [
            Switch(
              value: rememberMe,
              onChanged: onRememberMeChanged,
              activeColor: theme.colorScheme.primary,
            ),
            Text(
              AppTexts.rememberMe,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Login button
        CommonButton(
          text: AppTexts.loginButton,
          onPressed: onLoginPressed,
        ),
        const SizedBox(height: 16),
        // Forgot password link
        Center(
          child: TextButton(
            onPressed: () => context.push('/forgot-password'),
            child: Text(
              AppTexts.forgotPasswordLink,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Register link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppTexts.dontHaveAccount,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            TextButton(
              onPressed: () => context.push('/register'),
              child: Text(
                AppTexts.registerButton,
                style: theme.textTheme.bodyMedium?.copyWith(
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
