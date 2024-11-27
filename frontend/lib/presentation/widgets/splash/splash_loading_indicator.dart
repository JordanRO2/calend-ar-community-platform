import 'package:flutter/material.dart';
import 'package:frontend/presentation/configuration/theme/app_theme.dart';

class SplashLoadingIndicator extends StatelessWidget {
  const SplashLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final backgroundColor = theme.colorScheme.surface;

    // Determina el mejor color para el indicador basado en el fondo
    final visibleColor = AppTheme.getContrastingTextColor(backgroundColor);

    // Calcula el tamaño del indicador basado en el ancho de la pantalla
    double indicatorSize = screenWidth * 0.08;
    indicatorSize = indicatorSize.clamp(24, 60);

    return SizedBox(
      width: indicatorSize,
      height: indicatorSize,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(visibleColor),
        strokeWidth: 4.0, // Ajusta el grosor del borde del indicador
      ),
    );
  }
}
