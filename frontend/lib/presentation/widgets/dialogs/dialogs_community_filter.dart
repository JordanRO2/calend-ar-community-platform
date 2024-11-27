// frontend/lib/presentation/widgets/dialogs/community_filter_dialogs.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';
import 'package:frontend/presentation/providers/community_provider.dart';

class CommunityFilterDialogs {
  static Future<String?> showTypeDialog(BuildContext context) async {
    final communityProvider = context.read<CommunityProvider>();
    // Obtener los tipos de comunidad del provider
    final types = await communityProvider.getTypes();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppTexts.selectType),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: types
                .map(
                  (type) => ListTile(
                    title: Text(type),
                    onTap: () => Navigator.pop(context, type),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppTexts.cancel),
          ),
        ],
      ),
    );
  }

  static Future<String?> showCategoryDialog(BuildContext context) async {
    final communityProvider = context.read<CommunityProvider>();
    // Obtener las categorías de comunidad del provider
    final categories = await communityProvider.getCategories();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppTexts.selectCategory),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: categories
                .map(
                  (category) => ListTile(
                    title: Text(category),
                    onTap: () => Navigator.pop(context, category),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppTexts.cancel),
          ),
        ],
      ),
    );
  }

  static Future<String?> showLocationDialog(BuildContext context) async {
    final communityProvider = context.read<CommunityProvider>();
    // Obtener las ubicaciones de comunidad del provider
    final locations = await communityProvider.getLocations();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppTexts.selectLocation),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: locations
                .map(
                  (location) => ListTile(
                    title: Text(location),
                    onTap: () => Navigator.pop(context, location),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppTexts.cancel),
          ),
        ],
      ),
    );
  }
}
