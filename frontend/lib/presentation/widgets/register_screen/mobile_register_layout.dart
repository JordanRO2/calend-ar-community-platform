// lib/presentation/widgets/register_screen/mobile_register_layout.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/common/common_gradient_background.dart';
import 'package:frontend/presentation/widgets/register_screen/register_form_container.dart';

class MobileRegisterLayout extends StatelessWidget {
  const MobileRegisterLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CommonGradientBackground(
        child: SafeArea(
          child: RegisterFormContainer(isWeb: false),
        ),
      ),
    );
  }
}
