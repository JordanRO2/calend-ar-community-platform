// frontend/lib/presentation/widgets/home_screen/tabs/profile_tab.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';
import 'package:frontend/presentation/widgets/common/common_avatar.dart';
import 'package:frontend/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/widgets/common/common_snackbar.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/domain/entities/user.dart';
import 'package:frontend/presentation/widgets/common/common_loading_indicator.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: ProfileAppBar(),
      body: ProfileContent(),
    );
  }
}

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(AppTexts.profileTitle),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: AppTexts.settingsTooltip,
          onPressed: () => context.push('/settings'),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await context.read<UserProvider>().logout();
      if (context.mounted) {
        context.go('/login');
        context.showSuccessSnackBar(AppTexts.logoutSuccess);
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(AppTexts.logoutError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CommonLoadingIndicator());
        }

        final user = provider.currentUser;

        if (!provider.isAuthenticated || user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  AppTexts.sessionExpired,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text(AppTexts.loginButton),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.checkAuthentication();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileHeader(user: user),
                const SizedBox(height: 24),
                const ProfileActions(),
                const SizedBox(height: 24),
                ProfileRoleInfo(user: user),
                const SizedBox(height: 24),
                LogoutButton(onLogout: () => _handleLogout(context)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final User user;

  const ProfileHeader({
    super.key,
    required this.user,
  });

  Future<void> _updateProfileImage(BuildContext context, User user) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && context.mounted) {
        final provider = context.read<UserProvider>();
        final avatarUrl = await provider.uploadAvatar(image);
        if (avatarUrl != null && context.mounted) {
          await provider.updateProfile(
            name: user.name,
            email: user.email,
            avatarUrl: avatarUrl,
          );
          context.showSuccessSnackBar(AppTexts.avatarUpdateSuccess);
        }
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(AppTexts.avatarUploadError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CommonAvatar(
                  radius: 50,
                  imageUrl: user.avatarUrl,
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: Semantics(
                    label: AppTexts.updateAvatar,
                    child: IconButton(
                      onPressed: () => _updateProfileImage(context, user),
                      icon: const Icon(Icons.camera_alt),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: const CircleBorder(),
                      ),
                      tooltip: AppTexts.updateAvatarTooltip,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileActions extends StatelessWidget {
  const ProfileActions({super.key});

  Future<void> _showDisableAccountDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppTexts.disableAccountTitle),
        content: const Text(AppTexts.disableAccountConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppTexts.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppTexts.disableAccount,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<UserProvider>().disableUser();
        context.showSuccessSnackBar(AppTexts.accountDisabled);
        context.go('/login');
      } catch (e) {
        context.showErrorSnackBar(AppTexts.disableAccountError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: const Column(
        children: [
          ProfileActionTile(
            icon: Icons.edit,
            title: AppTexts.editProfile,
            route: '/profile/edit',
          ),
          Divider(height: 1),
          ProfileActionTile(
            icon: Icons.lock_outline,
            title: AppTexts.changePassword,
            route: '/profile/password',
          ),
          Divider(height: 1),
          ProfileActionTile(
            icon: Icons.delete_outline,
            title: AppTexts.disableAccount,
            isDestructive: true,
            onTapOverride: true, // Indica que se manejará manualmente
          ),
        ],
      ),
    );
  }
}

class ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? route;
  final bool isDestructive;
  final bool onTapOverride;

  const ProfileActionTile({
    super.key,
    required this.icon,
    required this.title,
    this.route,
    this.isDestructive = false,
    this.onTapOverride = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        isDestructive ? theme.colorScheme.error : theme.colorScheme.primary;

    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? theme.colorScheme.error : null,
          fontWeight: isDestructive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        if (onTapOverride && title == AppTexts.disableAccount) {
          // Manejar desactivación de cuenta manualmente
          // Este caso será manejado en el widget padre (ProfileActions)
          // Aquí no hacemos nada
        } else if (route != null) {
          context.push(route!);
        }
      },
    );
  }
}

class ProfileRoleInfo extends StatelessWidget {
  final User user;

  const ProfileRoleInfo({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final role = user.role.toUpperCase();

    String description = '';
    if (user.isAdmin()) {
      description = AppTexts.adminDescription;
    } else if (user.isModerator()) {
      description = AppTexts.moderatorDescription;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTexts.accountType,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                role,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutButton({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onLogout,
      icon: const Icon(Icons.logout),
      label: const Text(AppTexts.logoutButton),
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.error,
        side: BorderSide(
          color: Theme.of(context).colorScheme.error,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
