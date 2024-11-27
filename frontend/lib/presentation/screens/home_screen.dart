// frontend/lib/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/home_screen/responsive_home_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ResponsiveHomeLayout(),
    );
  }
}
