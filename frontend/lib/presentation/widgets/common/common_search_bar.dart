// common_search_bar.dart
import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/common/common_responsive_breakpoints.dart';

class CommonSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  const CommonSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWeb = context.isWeb;

    return Container(
      constraints: BoxConstraints(
        maxWidth: isWeb ? 600 : double.infinity,
      ),
      child: TextField(
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isWeb ? 12 : 8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isWeb ? 20 : 16,
            vertical: isWeb ? 16 : 12,
          ),
        ),
        style: isWeb ? theme.textTheme.titleMedium : theme.textTheme.bodyLarge,
      ),
    );
  }
}
