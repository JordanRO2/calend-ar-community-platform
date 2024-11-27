// relative path: frontend/lib/application/use_cases/events/get_featured_events_use_case.dart

import 'package:frontend/domain/entities/event.dart';
import 'package:frontend/domain/interfaces/event_repository.dart';

class GetFeaturedEventsUseCase {
  final EventRepository eventRepository;

  GetFeaturedEventsUseCase(this.eventRepository);

  /// Obtiene una lista de eventos destacados con paginación.
  Future<List<Event>> execute(int page, int limit) async {
    try {
      return await eventRepository.getFeaturedEvents(page, limit);
    } catch (e) {
      throw Exception('Error al obtener eventos destacados: $e');
    }
  }
}
