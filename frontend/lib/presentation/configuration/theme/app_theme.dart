// frontend/lib/presentation/configuration/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const double baseFontSize = 14.0;

  /// Determina si un color es oscuro o claro.
  static bool isDarkColor(Color color) {
    // Usamos computeLuminance para obtener la luminancia del color.
    // Un valor menor a 0.5 se considera oscuro.
    return color.computeLuminance() < 0.5;
  }

  /// Devuelve el mejor color de texto (blanco o negro) basado en el color de fondo.
  static Color getContrastingTextColor(Color backgroundColor) {
    return isDarkColor(backgroundColor) ? Colors.white : Colors.black;
  }

  /// Genera el tema claro basado en un color semilla.
  static ThemeData generateTheme(Color seedColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );

    // Obtenemos el color de texto contrastante para el fondo.
    final textColor = getContrastingTextColor(colorScheme.surface);

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        titleTextStyle: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: baseFontSize * 1.25,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: textColor,
          fontSize: baseFontSize * 1.125,
        ),
        bodyMedium: TextStyle(
          color: textColor,
          fontSize: baseFontSize,
        ),
        bodySmall: TextStyle(
          color: textColor.withOpacity(0.7),
          fontSize: baseFontSize * 0.875,
        ),
        headlineLarge: TextStyle(
          color: colorScheme.primary,
          fontSize: baseFontSize * 2.0,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: colorScheme.onSurface,
          fontSize: baseFontSize * 1.5,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          textStyle: const TextStyle(
            fontSize: baseFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      cardTheme: CardTheme(
        color: colorScheme.surface,
        margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.secondaryContainer,
        labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
        secondaryLabelStyle: TextStyle(color: colorScheme.onSecondary),
        padding: const EdgeInsets.all(4.0),
      ),
    );
  }

  /// Genera el tema oscuro basado en un color semilla.
  static ThemeData generateDarkTheme(Color seedColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    // Obtenemos el color de texto contrastante para el fondo.
    final textColor = getContrastingTextColor(colorScheme.surface);

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: baseFontSize * 1.25,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: textColor,
          fontSize: baseFontSize * 1.125,
        ),
        bodyMedium: TextStyle(
          color: textColor,
          fontSize: baseFontSize,
        ),
        bodySmall: TextStyle(
          color: textColor.withOpacity(0.7),
          fontSize: baseFontSize * 0.875,
        ),
        headlineLarge: TextStyle(
          color: colorScheme.primary,
          fontSize: baseFontSize * 2.0,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: colorScheme.onSurface,
          fontSize: baseFontSize * 1.5,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          textStyle: const TextStyle(
            fontSize: baseFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      cardTheme: CardTheme(
        color: colorScheme.surface,
        margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.secondaryContainer,
        labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
        secondaryLabelStyle: TextStyle(color: colorScheme.onSecondary),
        padding: const EdgeInsets.all(4.0),
      ),
    );
  }
}
