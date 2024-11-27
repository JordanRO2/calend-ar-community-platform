// lib/presentation/widgets/register_screen/web_register_layout.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/common/common_gradient_background.dart';
import 'package:frontend/presentation/widgets/register_screen/register_form_container.dart';
import 'package:frontend/presentation/widgets/common/common_logo.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';

class WebRegisterLayout extends StatelessWidget {
  const WebRegisterLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CommonGradientBackground(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CommonLogo(
                    height: 120,
                    logoColor: Colors.white,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    AppTexts.webRegisterTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppTexts.webRegisterSubtitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        const Expanded(
          child: RegisterFormContainer(isWeb: true),
        ),
      ],
    );
  }
}
