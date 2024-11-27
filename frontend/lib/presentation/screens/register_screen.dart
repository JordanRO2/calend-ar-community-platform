// lib/presentation/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/register_screen/responsive_register_layout.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ResponsiveRegisterLayout(),
    );
  }
}
