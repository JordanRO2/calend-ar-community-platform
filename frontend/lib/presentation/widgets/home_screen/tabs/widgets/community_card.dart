// frontend/lib/presentation/widgets/home_screen/tabs/widgets/community_card.dart

import 'package:flutter/material.dart';
import 'package:frontend/domain/entities/community.dart';
import 'package:frontend/presentation/configuration/assets/app_images.dart';

class CommunityCard extends StatelessWidget {
  final Community community;
  final VoidCallback onTap;

  const CommunityCard({
    super.key,
    required this.community,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determinar el ancho disponible para ajustar los tamaños de fuente
        double screenWidth = constraints.maxWidth;
        double titleFontSize = screenWidth > 600 ? 20 : 16;
        double descriptionFontSize = screenWidth > 600 ? 16 : 14;
        double infoFontSize = screenWidth > 600 ? 14 : 12;

        return Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 4,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen de la comunidad con FadeInImage para mejor UX
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: FadeInImage.assetNetwork(
                    placeholder:
                        AppImages.defaultCommunity, // Imagen de placeholder
                    image: community.imageUrl ?? AppImages.defaultCommunity,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        AppImages.defaultCommunity,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre de la comunidad
                      Text(
                        community.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: titleFontSize,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Descripción de la comunidad
                      Text(
                        community.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                              fontSize: descriptionFontSize,
                            ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      // Información adicional: Categoría y Ubicación
                      _buildInfoRow(
                        context,
                        Icons.category,
                        community.category,
                        fontSize: infoFontSize,
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        context,
                        Icons.location_on,
                        community.location,
                        fontSize: infoFontSize,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text,
      {double fontSize = 12}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: fontSize,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
