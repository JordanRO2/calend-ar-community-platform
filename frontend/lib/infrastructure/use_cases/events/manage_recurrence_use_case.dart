// relative path: frontend/lib/application/use_cases/events/manage_recurrence_use_case.dart

import 'package:frontend/domain/interfaces/event_repository.dart';

class ManageRecurrenceUseCase {
  final EventRepository eventRepository;

  ManageRecurrenceUseCase(this.eventRepository);

  /// Gestiona la recurrencia de un evento.
  Future<void> execute(
      String eventId, Map<String, dynamic> recurrenceData) async {
    try {
      await eventRepository.manageRecurrence(eventId, recurrenceData);
    } catch (e) {
      throw Exception('Error al gestionar la recurrencia del evento: $e');
    }
  }
}
