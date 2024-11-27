// frontend/lib/presentation/widgets/login_screen/web_side_panel.dart
import 'package:flutter/material.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';
import 'package:frontend/presentation/widgets/common/common_logo.dart';
import 'package:frontend/presentation/widgets/common/common_gradient_background.dart';

class WebSidePanel extends StatelessWidget {
  const WebSidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CommonGradientBackground(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              const CommonLogo(
                height: 120,
                logoColor: Colors.white, // Color consistente y visible
              ),
              const SizedBox(height: 32),

              // Título de Login Web
              Text(
                AppTexts.webLoginTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white, // Color consistente con móvil
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtítulo de Login Web
              Text(
                AppTexts.webLoginSubtitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white
                      .withOpacity(0.9), // Color consistente con móvil
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
