// frontend/lib/presentation/widgets/common/common_app_bar.dart

import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSave;

  const CommonAppBar({
    super.key,
    required this.title,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        if (onSave != null)
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: onSave,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
