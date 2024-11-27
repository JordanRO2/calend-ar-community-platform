// relative path: frontend/lib/application/use_cases/events/filter_events_use_case.dart

import 'package:frontend/domain/entities/event.dart';
import 'package:frontend/domain/interfaces/event_repository.dart';

class FilterEventsUseCase {
  final EventRepository eventRepository;

  FilterEventsUseCase(this.eventRepository);

  /// Filtra eventos según los criterios especificados y devuelve una lista de eventos paginada.
  Future<List<Event>> execute(
      Map<String, dynamic> filters, int page, int limit) async {
    try {
      return await eventRepository.filterEvents(filters, page, limit);
    } catch (e) {
      throw Exception('Error al filtrar eventos: $e');
    }
  }
}
