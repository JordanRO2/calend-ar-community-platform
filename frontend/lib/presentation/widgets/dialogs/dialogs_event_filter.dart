import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/presentation/configuration/assets/app_images.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/providers/community_provider.dart';
import 'package:frontend/presentation/providers/event_provider.dart';

class EventFilterDialogs {
  static Future<String?> showCategoryDialog(BuildContext context) async {
    final eventProvider = context.read<EventProvider>();
    // Obtener las categorías del provider
    final categories = await eventProvider.getCategories();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppTexts.selectCategory),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: categories.map((category) => 
              ListTile(
                title: Text(category),
                onTap: () => Navigator.pop(context, category),
              ),
            ).toList(),
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

  static Future<String?> showCommunityDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppTexts.selectCommunity),
        content: Consumer<CommunityProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final communities = provider.communities;

            if (communities.isEmpty) {
              return const Center(
                child: Text(AppTexts.noCommunitiesFoundMessage),
              );
            }
            
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: AppTexts.searchCommunitiesHint,
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      provider.filterCommunities({'search': value}, 1, 10);
                    },
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: communities.length,
                    itemBuilder: (context, index) {
                      final community = communities[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            community.imageUrl ?? AppImages.defaultCommunity,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              AppImages.defaultCommunity,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(community.name),
                        subtitle: Text(community.category),
                        onTap: () => Navigator.pop(context, community.id),
                      );
                    },
                  ),
                ],
              ),
            );
          },
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

  static Future<String?> showDateDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppTexts.selectDate),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Hoy'),
                onTap: () => Navigator.pop(context, DateTime.now().toIso8601String()),
              ),
              ListTile(
                title: const Text('Esta semana'),
                onTap: () {
                  final now = DateTime.now();
                  final endOfWeek = now.add(const Duration(days: 7));
                  Navigator.pop(context, endOfWeek.toIso8601String());
                },
              ),
              ListTile(
                title: const Text('Este mes'),
                onTap: () {
                  final now = DateTime.now();
                  final endOfMonth = DateTime(now.year, now.month + 1, 0);
                  Navigator.pop(context, endOfMonth.toIso8601String());
                },
              ),
              ListTile(
                title: const Text('Personalizado...'),
                onTap: () async {
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null && context.mounted) {
                    Navigator.pop(
                      context, 
                      json.encode({
                        'start': picked.start.toIso8601String(),
                        'end': picked.end.toIso8601String(),
                      }),
                    );
                  }
                },
              ),
            ],
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