// frontend/lib/presentation/widgets/home_screen/tabs/widgets/community_list.dart

import 'package:flutter/material.dart';
import 'package:frontend/domain/entities/community.dart';
import 'package:frontend/presentation/widgets/home_screen/tabs/widgets/community_card.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';

class CommunityList extends StatelessWidget {
  final List<Community> communities;
  final Function(Community) onCommunityTap;

  const CommunityList({
    super.key,
    required this.communities,
    required this.onCommunityTap,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener el ancho de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;

    // Definir el ancho de cada CommunityCard según el tamaño de la pantalla
    double cardWidth;
    if (screenWidth >= 1200) {
      cardWidth = 300;
    } else if (screenWidth >= 900) {
      cardWidth = 250;
    } else if (screenWidth >= 600) {
      cardWidth = 200;
    } else {
      cardWidth = 150;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: communities.isEmpty
          ? Center(
              child: Text(
                AppTexts.noCommunitiesFound,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            )
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: communities.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final community = communities[index];
                return SizedBox(
                  width: cardWidth,
                  child: CommunityCard(
                    community: community,
                    onTap: () => onCommunityTap(community),
                  ),
                );
              },
            ),
    );
  }
}
