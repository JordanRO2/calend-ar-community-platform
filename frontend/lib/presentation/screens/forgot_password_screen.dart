// lib/presentation/screens/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/forgot_password_screen/responsive_forgot_password_layout.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ResponsiveForgotPasswordLayout(),
    );
  }
}
