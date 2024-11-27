import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CommonLogo extends StatelessWidget {
  final double height;
  final String assetPath;
  final Color? logoColor;

  const CommonLogo({
    super.key,
    this.height = 100,
    this.assetPath = 'assets/images/logo.svg',
    this.logoColor, // Permitir un color personalizado opcional
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Si no se especifica un color, usa theme.disabledColor como predeterminado
    final color = logoColor ?? theme.colorScheme.onSurface;

    return SvgPicture.asset(
      assetPath,
      height: height,
      colorFilter: ColorFilter.mode(
        color,
        BlendMode.srcIn,
      ),
    );
  }
}
