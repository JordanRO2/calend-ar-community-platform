// frontend/lib/presentation/widgets/home_screen/tabs/settings_tab.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';
import 'package:frontend/presentation/widgets/common/common_section_title.dart';
import 'package:frontend/presentation/widgets/common/common_snackbar.dart';
import 'package:frontend/presentation/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Proveedor de configuraciones ya está proporcionado en main.dart
    return const Scaffold(
      appBar: SettingsAppBar(),
      body: SettingsContent(),
    );
  }
}

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(AppTexts.settingsTitle),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: AppTexts.refreshTooltip,
          onPressed: () {
            // Acción de refrescar configuraciones
            context.read<SettingsProvider>().loadSettings();
            context.showSuccessSnackBar(AppTexts.settingsRefreshed);
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Detectar el tamaño de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 800; // Umbral para pantallas grandes

    // Definir el padding horizontal según el tamaño de la pantalla
    final horizontalPadding = isLargeScreen ? 32.0 : 16.0;
    const maxContentWidth =
        800.0; // Ancho máximo para contenido en pantallas grandes

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: maxContentWidth,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16.0,
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsSection(
                title: AppTexts.accountSettings,
                children: [
                  SettingsOption(
                    title: AppTexts.editProfile,
                    icon: Icons.edit,
                    route: '/profile/edit',
                  ),
                  SettingsOption(
                    title: AppTexts.changePassword,
                    icon: Icons.lock_outline,
                    route: '/profile/password',
                  ),
                ],
              ),
              SizedBox(height: 24),
              SettingsSection(
                title: AppTexts.appearance,
                children: [
                  ToggleSettingsOption(
                    title: AppTexts.darkMode,
                    icon: Icons.dark_mode,
                    settingKey: 'darkMode',
                  ),
                  DropdownSettingsOption(
                    title: AppTexts.language,
                    icon: Icons.language,
                    settingKey: 'language',
                    options: ['Español', 'Inglés', 'Francés'],
                  ),
                ],
              ),
              SizedBox(height: 24),
              SettingsSection(
                title: AppTexts.notifications,
                children: [
                  ToggleSettingsOption(
                    title: AppTexts.emailNotifications,
                    icon: Icons.email,
                    settingKey: 'emailNotifications',
                  ),
                  ToggleSettingsOption(
                    title: AppTexts.pushNotifications,
                    icon: Icons.notifications,
                    settingKey: 'pushNotifications',
                  ),
                ],
              ),
              SizedBox(height: 24),
              SettingsSection(
                title: AppTexts.privacy,
                children: [
                  ToggleSettingsOption(
                    title: AppTexts.shareData,
                    icon: Icons.share,
                    settingKey: 'shareData',
                  ),
                ],
              ),
              SizedBox(height: 24),
              SettingsSection(
                title: AppTexts.general,
                children: [
                  ActionSettingsOption(
                    title: AppTexts.termsOfService,
                    icon: Icons.description,
                    route: '/terms',
                  ),
                  ActionSettingsOption(
                    title: AppTexts.privacyPolicy,
                    icon: Icons.policy,
                    route: '/privacy',
                  ),
                ],
              ),
              SizedBox(height: 24),
              LogoutButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    // Detectar si es una pantalla grande para ajustar la disposición
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonSectionTitle(title: title),
        const SizedBox(height: 16),
        isLargeScreen
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: children.map((widget) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: widget,
                    ),
                  );
                }).toList(),
              )
            : Column(
                children: children,
              ),
      ],
    );
  }
}

class SettingsOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;

  const SettingsOption({
    super.key,
    required this.title,
    required this.icon,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    // Ajustar el padding y tamaño según el tamaño de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 800;

    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(route),
    );
  }
}

class ToggleSettingsOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final String settingKey;

  const ToggleSettingsOption({
    super.key,
    required this.title,
    required this.icon,
    required this.settingKey,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, provider, child) {
        bool currentValue = provider.getSetting(settingKey) ?? false;

        return SwitchListTile(
          secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(title),
          value: currentValue,
          onChanged: (bool value) {
            provider.updateSetting(settingKey, value);
            context.showSuccessSnackBar(AppTexts.settingUpdated);
          },
        );
      },
    );
  }
}

class DropdownSettingsOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final String settingKey;
  final List<String> options;

  const DropdownSettingsOption({
    super.key,
    required this.title,
    required this.icon,
    required this.settingKey,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, provider, child) {
        String currentValue = provider.getSetting(settingKey) ?? options.first;

        return ListTile(
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(title),
          trailing: DropdownButton<String>(
            value: currentValue,
            onChanged: (String? newValue) {
              if (newValue != null) {
                provider.updateSetting(settingKey, newValue);
                context.showSuccessSnackBar(AppTexts.settingUpdated);
              }
            },
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class ActionSettingsOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;

  const ActionSettingsOption({
    super.key,
    required this.title,
    required this.icon,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(route),
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppTexts.logoutConfirmationTitle),
        content: const Text(AppTexts.logoutConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppTexts.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppTexts.logoutButton,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<SettingsProvider>().logout();
        context.go('/login');
        context.showSuccessSnackBar(AppTexts.logoutSuccess);
      } catch (e) {
        context.showErrorSnackBar(AppTexts.logoutError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ajustar el tamaño del botón según el tamaño de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 800;

    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _confirmLogout(context),
        icon: const Icon(Icons.logout),
        label: const Text(AppTexts.logoutButton),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).colorScheme.error,
          padding: EdgeInsets.symmetric(
            vertical: isLargeScreen ? 20 : 16,
            horizontal: isLargeScreen ? 32 : 24,
          ),
          textStyle: TextStyle(
            fontSize: isLargeScreen ? 18 : 16,
          ),
        ),
      ),
    );
  }
}
