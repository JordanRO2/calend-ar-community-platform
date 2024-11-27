// frontend/lib/presentation/widgets/home_screen/tabs/widgets/event_card.dart

import 'package:flutter/material.dart';
import 'package:frontend/domain/entities/event.dart';
import 'package:frontend/presentation/configuration/assets/app_images.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Obtener el ancho disponible
        final screenWidth = constraints.maxWidth;

        // Definir tamaños de fuente basados en el ancho de la pantalla
        double titleFontSize = screenWidth > 600 ? 20 : 16;
        double descriptionFontSize = screenWidth > 600 ? 16 : 14;
        double infoFontSize = screenWidth > 600 ? 14 : 12;
        double ratingFontSize = screenWidth > 600 ? 14 : 12;

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
                // Imagen del evento con FadeInImage
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      FadeInImage.assetNetwork(
                        placeholder:
                            AppImages.defaultEvent, // Imagen placeholder
                        image: event.imageUrl ?? AppImages.defaultEvent,
                        fit: BoxFit.cover,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            AppImages.defaultEvent,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                      if (event.isRecurring)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Semantics(
                            label: AppTexts.recurringEvent,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.repeat,
                                    size: 16,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    AppTexts.recurring,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          fontSize: descriptionFontSize,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Contenido del evento
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título del evento
                      Text(
                        event.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: titleFontSize,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Fecha y hora
                      _EventInfo(
                        icon: Icons.calendar_today_outlined,
                        text: _formatDate(event.dateTime),
                        fontSize: infoFontSize,
                      ),
                      const SizedBox(height: 4),
                      // Hora
                      _EventInfo(
                        icon: Icons.access_time_outlined,
                        text: _formatTime(event.dateTime),
                        fontSize: infoFontSize,
                      ),
                      const SizedBox(height: 4),
                      // Ubicación
                      _EventInfo(
                        icon: Icons.location_on_outlined,
                        text: event.location,
                        fontSize: infoFontSize,
                      ),
                      if (event.rating > 0) ...[
                        const SizedBox(height: 8),
                        // Rating
                        _RatingBar(
                          rating: event.rating,
                          fontSize: ratingFontSize,
                        ),
                      ],
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

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return AppTexts.noDate;
    return DateFormat.yMMMd().format(dateTime);
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return AppTexts.noTime;
    return DateFormat.jm().format(dateTime);
  }
}

class _EventInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  final double fontSize;

  const _EventInfo({
    required this.icon,
    required this.text,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = theme.colorScheme.onSurface.withOpacity(0.6);

    return Semantics(
      label: text,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: effectiveColor,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: effectiveColor,
                    fontSize: fontSize,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final double rating;
  final double fontSize;

  const _RatingBar({
    required this.rating,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullStars = rating.floor();
    final hasHalfStar = rating - fullStars >= 0.5;

    return Row(
      children: [
        ...List.generate(
          fullStars,
          (index) => const Icon(
            Icons.star,
            size: 16,
            color: Colors.amber,
          ),
        ),
        if (hasHalfStar)
          const Icon(
            Icons.star_half,
            size: 16,
            color: Colors.amber,
          ),
        ...List.generate(
          5 - fullStars - (hasHalfStar ? 1 : 0),
          (index) => const Icon(
            Icons.star_outline,
            size: 16,
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
        ),
      ],
    );
  }
}
