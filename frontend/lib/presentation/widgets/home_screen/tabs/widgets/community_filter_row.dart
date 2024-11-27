// frontend/lib/presentation/widgets/home_screen/tabs/widgets/community_filter_row.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/dialogs/dialogs_community_filter.dart';
import 'package:frontend/presentation/providers/community_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';

// Enum para identificar el tipo de filtro
enum FilterType { type, category, location }

class CommunityFilterRow extends StatelessWidget {
  const CommunityFilterRow({super.key});

  @override
  Widget build(BuildContext context) {
    // Determinar el tamaño de la pantalla para ajustar el diseño si es necesario
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        spacing: 8.0, // Espaciado horizontal entre chips
        runSpacing:
            8.0, // Espaciado vertical cuando los chips se envuelven a la siguiente línea
        children: [
          _FilterChip(
            label: AppTexts.type,
            onTap: () => _showFilterDialog(context, FilterType.type),
          ),
          _FilterChip(
            label: AppTexts.category,
            onTap: () => _showFilterDialog(context, FilterType.category),
          ),
          _FilterChip(
            label: AppTexts.location,
            onTap: () => _showFilterDialog(context, FilterType.location),
          ),
        ],
      ),
    );
  }

  // Función genérica para manejar la lógica de los filtros
  Future<void> _showFilterDialog(
      BuildContext context, FilterType filterType) async {
    String? selectedValue;

    Map<String, String> filterParams = {};
    switch (filterType) {
      case FilterType.type:
        selectedValue = await CommunityFilterDialogs.showTypeDialog(context);
        break;
      case FilterType.category:
        selectedValue =
            await CommunityFilterDialogs.showCategoryDialog(context);
        break;
      case FilterType.location:
        selectedValue =
            await CommunityFilterDialogs.showLocationDialog(context);
        break;
    }

    if (selectedValue != null && context.mounted) {
      // Construir el parámetro de filtrado basado en el tipo
      Map<String, String> filterParams;
      switch (filterType) {
        case FilterType.type:
          filterParams = {'type': selectedValue};
          break;
        case FilterType.category:
          filterParams = {'category': selectedValue};
          break;
        case FilterType.location:
          filterParams = {'location': selectedValue};
          break;
      }

      // Aplicar el filtro utilizando el CommunityProvider
      final communityProvider =
          Provider.of<CommunityProvider>(context, listen: false);
      communityProvider.filterCommunities(
        filterParams,
        1,
        10,
      );
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      avatar: const Icon(Icons.arrow_drop_down, size: 18),
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(
        color: theme.colorScheme.outline.withOpacity(0.5),
      ),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      // Añadir una ligera animación al presionar
      elevation: 2,
      pressElevation: 4,
      shadowColor: theme.colorScheme.shadow,
    );
  }
}
