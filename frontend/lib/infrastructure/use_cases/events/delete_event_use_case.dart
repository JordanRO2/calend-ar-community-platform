// relative path: frontend/lib/application/use_cases/events/delete_event_use_case.dart

import 'package:frontend/domain/interfaces/event_repository.dart';

class DeleteEventUseCase {
  final EventRepository eventRepository;

  DeleteEventUseCase(this.eventRepository);

  /// Elimina un evento dado su ID.
  Future<void> execute(String eventId) async {
    try {
      await eventRepository.deleteEvent(eventId);
    } catch (e) {
      throw Exception('Error al eliminar el evento: $e');
    }
  }
}
