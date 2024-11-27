// frontend/lib/presentation/screens/login_screen/login_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/login_screen/responsive_login_layout.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ResponsiveLoginLayout(),
    );
  }
}