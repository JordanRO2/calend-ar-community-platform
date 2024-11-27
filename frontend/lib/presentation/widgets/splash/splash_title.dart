import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/common/common_section_title.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';
import 'package:frontend/presentation/configuration/theme/app_theme.dart';

class SplashTitle extends StatelessWidget {
  const SplashTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    // Determina el color de fondo y calcula el color visible para el texto
    final backgroundColor = theme.colorScheme.surface;
    final visibleTextColor = AppTheme.getContrastingTextColor(backgroundColor);

    // Ajusta dinámicamente el tamaño de la fuente según el ancho de la pantalla
    double fontSize = screenWidth * 0.05;
    fontSize = fontSize.clamp(20, 36);

    return CommonSectionTitle(
      title: AppTexts.splashScreenText,
      fontSize: fontSize,
      titleColor: visibleTextColor, // Usa el color visible calculado
    );
  }
}
