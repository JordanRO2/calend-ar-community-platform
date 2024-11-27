// relative path: frontend/lib/application/use_cases/events/cancel_event_use_case.dart

import 'package:frontend/domain/interfaces/event_repository.dart';

class CancelEventUseCase {
  final EventRepository eventRepository;

  CancelEventUseCase(this.eventRepository);

  /// Cancela un evento dado su ID.
  Future<void> execute(String eventId) async {
    try {
      await eventRepository.cancelEvent(eventId);
    } catch (e) {
      throw Exception('Error al cancelar el evento: $e');
    }
  }
}
