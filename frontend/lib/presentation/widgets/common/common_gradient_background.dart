// frontend/lib/presentation/widgets/common/common_gradient_background.dart

import 'package:flutter/material.dart';

class CommonGradientBackground extends StatelessWidget {
  final Widget? child;

  const CommonGradientBackground({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
