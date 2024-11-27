// common_community_list_item.dart
import 'package:flutter/material.dart';
import 'package:frontend/domain/entities/community.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/presentation/configuration/assets/app_images.dart';

class CommonCommunityListItem extends StatelessWidget {
  final Community community;
  final VoidCallback onTap;

  const CommonCommunityListItem({
    super.key,
    required this.community,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 800;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02), // 2% del ancho
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen de la comunidad
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: community.imageUrl ?? AppImages.defaultCommunity,
                  width: isLargeScreen ? 160 : 120,
                  height: isLargeScreen ? 160 : 120,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: isLargeScreen ? 160 : 120,
                    height: isLargeScreen ? 160 : 120,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(
                      Icons.group_outlined,
                      color: Colors.black54,
                      size: 40,
                    ),
                  ),
                  placeholder: (_, __) => Container(
                    width: isLargeScreen ? 160 : 120,
                    height: isLargeScreen ? 160 : 120,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(
                      Icons.group_outlined,
                      color: Colors.black54,
                      size: 40,
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.02), // 2% del ancho
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título con 2 líneas
                    Text(
                      community.name,
                      style: isLargeScreen
                          ? theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            )
                          : theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isLargeScreen ? 12 : 8),
                    // Ubicación
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            community.location,
                            style: isLargeScreen
                                ? theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.black54,
                                  )
                                : theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.black54,
                                  ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isLargeScreen ? 8 : 4),
                    // Tipo de comunidad
                    Row(
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            community.type,
                            style: isLargeScreen
                                ? theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.black54,
                                  )
                                : theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.black54,
                                  ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
