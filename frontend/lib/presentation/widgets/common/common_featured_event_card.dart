// common_featured_event_card.dart
import 'package:flutter/material.dart';
import 'package:frontend/domain/entities/event.dart';
import 'package:frontend/presentation/configuration/assets/app_images.dart';
import 'package:frontend/presentation/widgets/common/common_responsive_breakpoints.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommonFeaturedEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const CommonFeaturedEventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWeb = context.isWeb;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
      ),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: isWeb ? 400 : 300,
          height: isWeb ? 300 : 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen
              CachedNetworkImage(
                imageUrl: event.imageUrl ?? AppImages.defaultEvent,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Image.asset(
                  AppImages.defaultEvent,
                  fit: BoxFit.cover,
                ),
                placeholder: (_, __) => Image.asset(
                  AppImages.defaultEvent,
                  fit: BoxFit.cover,
                ),
              ),
              // Gradient Overlay
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              // Content
              Positioned(
                left: isWeb ? 24 : 16,
                right: isWeb ? 24 : 16,
                bottom: isWeb ? 24 : 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.title,
                      style: (isWeb
                              ? theme.textTheme.headlineSmall
                              : theme.textTheme.titleLarge)
                          ?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isWeb ? 8 : 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: (isWeb
                                    ? theme.textTheme.titleMedium
                                    : theme.textTheme.bodyLarge)
                                ?.copyWith(
                              color: Colors.white70,
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
