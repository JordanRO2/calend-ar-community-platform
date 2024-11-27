// frontend/lib/presentation/widgets/home_screen/tabs/widgets/community_grid.dart

import 'package:flutter/material.dart';
import 'package:frontend/domain/entities/community.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';
import 'package:frontend/presentation/widgets/home_screen/tabs/widgets/community_card.dart';

class CommunityGrid extends StatelessWidget {
  final List<Community> communities;
  final Function(Community) onCommunityTap;

  const CommunityGrid({
    super.key,
    required this.communities,
    required this.onCommunityTap,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener el ancho de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;

    // Determinar el número de columnas basado en el ancho de la pantalla
    int crossAxisCount;
    if (screenWidth >= 1200) {
      crossAxisCount = 4;
    } else if (screenWidth >= 900) {
      crossAxisCount = 3;
    } else if (screenWidth >= 600) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    // Determinar el aspecto de la relación de aspecto basado en el ancho de la pantalla
    double childAspectRatio;
    if (screenWidth >= 1200) {
      childAspectRatio = 1.0;
    } else if (screenWidth >= 900) {
      childAspectRatio = 0.95;
    } else if (screenWidth >= 600) {
      childAspectRatio = 0.9;
    } else {
      childAspectRatio = 0.85;
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      sliver: communities.isEmpty
          ? SliverToBoxAdapter(
              child: Center(
                child: Text(
                  AppTexts.noCommunitiesFound,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            )
          : SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= communities.length) {
                    return const SizedBox.shrink();
                  }
                  final community = communities[index];
                  return CommunityCard(
                    community: community,
                    onTap: () => onCommunityTap(community),
                  );
                },
                childCount: communities.length,
              ),
            ),
    );
  }
}
