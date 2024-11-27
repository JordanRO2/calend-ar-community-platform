// relative path: frontend/lib/application/use_cases/events/update_event_use_case.dart

import 'package:frontend/domain/entities/event.dart';
import 'package:frontend/domain/interfaces/event_repository.dart';

class UpdateEventUseCase {
  final EventRepository eventRepository;

  UpdateEventUseCase(this.eventRepository);

  /// Actualiza un evento existente.
  Future<void> execute(String eventId, Event event) async {
    try {
      await eventRepository.updateEvent(eventId, event);
    } catch (e) {
      throw Exception('Error al actualizar el evento: $e');
    }
  }
}
