// lib/presentation/widgets/register_screen/register_form_container.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/register_screen/register_form.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';

class RegisterFormContainer extends StatelessWidget {
  final bool isWeb;

  const RegisterFormContainer({
    super.key,
    required this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    // Calculamos el ancho máximo basado en el tamaño de la pantalla
    final maxWidth = isWeb ? 400.0 : screenSize.width * 0.9;

    // Calculamos el padding basado en el tamaño de la pantalla
    final horizontalPadding = isWeb ? 24.0 : screenSize.width * 0.05;

    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            minHeight: isWeb ? 500 : 0,
          ),
          margin: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 24,
          ),
          padding: EdgeInsets.all(isWeb ? 24 : 16),
          decoration: isWeb
              ? null
              : BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppTexts.registerTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.9),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppTexts.registerSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isWeb ? 32 : 24),
              const RegisterForm(),
            ],
          ),
        ),
      ),
    );
  }
}
