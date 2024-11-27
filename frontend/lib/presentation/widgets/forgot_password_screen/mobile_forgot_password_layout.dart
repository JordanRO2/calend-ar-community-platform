// lib/presentation/widgets/forgot_password_screen/mobile_forgot_password_layout.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/common/common_gradient_background.dart';
import 'package:frontend/presentation/widgets/forgot_password_screen/forgot_password_form_container.dart';

class MobileForgotPasswordLayout extends StatelessWidget {
  const MobileForgotPasswordLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CommonGradientBackground(
        child: SafeArea(
          child: ForgotPasswordFormContainer(isWeb: false),
        ),
      ),
    );
  }
}
