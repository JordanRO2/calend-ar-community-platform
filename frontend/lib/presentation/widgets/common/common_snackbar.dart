// frontend/lib/presentation/widgets/common/common_snackbar.dart

import 'package:flutter/material.dart';

enum SnackBarType { success, error, info, warning }

class CommonSnackBar extends SnackBar {
  CommonSnackBar({
    super.key,
    required String message,
    SnackBarType type = SnackBarType.info,
    VoidCallback? onUndo,
    super.duration = const Duration(seconds: 4),
    super.behavior = SnackBarBehavior.floating,
  }) : super(
          content: _SnackBarContent(
            message: message,
            type: type,
            onUndo: onUndo,
          ),
          backgroundColor: _getBackgroundColor(type),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.all(16),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          dismissDirection: DismissDirection.horizontal,
        );

  static Color _getBackgroundColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Colors.green.shade800;
      case SnackBarType.error:
        return Colors.red.shade800;
      case SnackBarType.warning:
        return Colors.orange.shade800;
      case SnackBarType.info:
        return Colors.blue.shade800;
    }
  }

  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle_outline;
      case SnackBarType.error:
        return Icons.error_outline;
      case SnackBarType.warning:
        return Icons.warning_amber_rounded;
      case SnackBarType.info:
        return Icons.info_outline;
    }
  }
}

class _SnackBarContent extends StatelessWidget {
  final String message;
  final SnackBarType type;
  final VoidCallback? onUndo;

  const _SnackBarContent({
    required this.message,
    required this.type,
    this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          CommonSnackBar._getIcon(type),
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        if (onUndo != null) ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: onUndo,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text('DESHACER'),
          ),
        ],
      ],
    );
  }
}

// Extensión para facilitar el uso del SnackBar
extension CommonShowSnackBar on BuildContext {
  void showSuccessSnackBar(String message, {VoidCallback? onUndo}) {
    _showSnackBar(message, SnackBarType.success, onUndo: onUndo);
  }

  void showErrorSnackBar(String message, {VoidCallback? onUndo}) {
    _showSnackBar(message, SnackBarType.error, onUndo: onUndo);
  }

  void showWarningSnackBar(String message, {VoidCallback? onUndo}) {
    _showSnackBar(message, SnackBarType.warning, onUndo: onUndo);
  }

  void showInfoSnackBar(String message, {VoidCallback? onUndo}) {
    _showSnackBar(message, SnackBarType.info, onUndo: onUndo);
  }

  void _showSnackBar(String message, SnackBarType type,
      {VoidCallback? onUndo}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        CommonSnackBar(
          message: message,
          type: type,
          onUndo: onUndo,
        ),
      );
  }
}
