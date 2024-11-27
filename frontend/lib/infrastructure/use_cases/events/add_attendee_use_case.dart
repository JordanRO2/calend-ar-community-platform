// relative path: frontend/lib/application/use_cases/events/add_attendee_use_case.dart

import 'package:frontend/domain/interfaces/event_repository.dart';

class AddAttendeeUseCase {
  final EventRepository eventRepository;

  AddAttendeeUseCase(this.eventRepository);

  /// Añade un asistente a un evento.
  Future<void> execute(String eventId, String userId) async {
    try {
      await eventRepository.addAttendee(eventId, userId);
    } catch (e) {
      throw Exception('Error al añadir asistente al evento: $e');
    }
  }
}
