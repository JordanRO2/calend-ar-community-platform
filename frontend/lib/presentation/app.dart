// frontend/lib/presentation/app.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/routes/app_router.dart';
import 'package:frontend/presentation/configuration/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/providers/settings_provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        bool isDarkMode = settingsProvider.getSetting('darkMode') ?? false;
        return MaterialApp.router(
          title: 'Calend.ar',
          routerConfig: AppRouter.createRouter(),
          theme: AppTheme.generateTheme(const Color(0xFFEA899A)),
          darkTheme: AppTheme.generateDarkTheme(const Color(0xFFEA899A)),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
