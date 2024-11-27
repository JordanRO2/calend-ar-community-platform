// frontend/lib/presentation/widgets/common/common_bubble.dart

import 'package:flutter/material.dart';

class CommonBubble extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CommonBubble({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Colores según el estado
    final backgroundColor = isSelected
        ? theme.colorScheme.surface // Fondo para seleccionado
        : theme.colorScheme.onSurface; // Fondo para no seleccionado

    final iconColor = isSelected
        ? theme.colorScheme.primary // Ícono para seleccionado
        : theme.colorScheme.onPrimary; // Ícono para no seleccionado

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(4.0),
        child: CircleAvatar(
          radius: 25,
          backgroundColor: backgroundColor,
          child: Icon(
            icon,
            color: iconColor,
            size: 24, // Tamaño del ícono
          ),
        ),
      ),
    );
  }
}
