// event_list_item.dart
import 'package:flutter/material.dart';
import 'package:frontend/domain/entities/event.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/presentation/configuration/assets/app_images.dart';

class EventListItem extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const EventListItem({
    super.key,
    required this.event,
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
              // Imagen del evento
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: event.imageUrl ?? AppImages.defaultEvent,
                  width: isLargeScreen ? 160 : 120,
                  height: isLargeScreen ? 160 : 120,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: isLargeScreen ? 160 : 120,
                    height: isLargeScreen ? 160 : 120,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(
                      Icons.event,
                      color: Colors.black54,
                      size: 40,
                    ),
                  ),
                  placeholder: (_, __) => Container(
                    width: isLargeScreen ? 160 : 120,
                    height: isLargeScreen ? 160 : 120,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(
                      Icons.event,
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
                      event.title,
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
                            event.location,
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
                    // Fecha y hora
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatDateTime(event.dateTime),
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

  String _formatDateTime(DateTime dateTime) {
    // Formatear la fecha y hora según tus necesidades
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
