// lib/presentation/widgets/login_screen/mobile_login_layout.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/common/common_gradient_background.dart';
import 'package:frontend/presentation/widgets/login_screen/login_form_container.dart';

class MobileLoginLayout extends StatelessWidget {
  const MobileLoginLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CommonGradientBackground(
        child: SafeArea(
          child: LoginFormContainer(isWeb: false),
        ),
      ),
    );
  }
}
