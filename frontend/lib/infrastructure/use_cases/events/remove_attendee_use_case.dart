// relative path: frontend/lib/application/use_cases/events/remove_attendee_use_case.dart

import 'package:frontend/domain/interfaces/event_repository.dart';

class RemoveAttendeeUseCase {
  final EventRepository eventRepository;

  RemoveAttendeeUseCase(this.eventRepository);

  /// Elimina un asistente de un evento.
  Future<void> execute(String eventId, String userId) async {
    try {
      await eventRepository.removeAttendee(eventId, userId);
    } catch (e) {
      throw Exception('Error al eliminar asistente del evento: $e');
    }
  }
}
