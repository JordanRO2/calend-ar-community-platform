// relative path: frontend/lib/application/use_cases/events/get_event_details_use_case.dart

import 'package:frontend/domain/entities/event.dart';
import 'package:frontend/domain/interfaces/event_repository.dart';

class GetEventDetailsUseCase {
  final EventRepository eventRepository;

  GetEventDetailsUseCase(this.eventRepository);

  /// Obtiene los detalles de un evento específico.
  Future<Event?> execute(String eventId) async {
    try {
      return await eventRepository.getEventById(eventId);
    } catch (e) {
      throw Exception('Error al obtener los detalles del evento: $e');
    }
  }
}
