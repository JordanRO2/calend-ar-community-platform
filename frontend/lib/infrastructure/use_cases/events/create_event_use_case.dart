// relative path: frontend/lib/application/use_cases/events/create_event_use_case.dart

import 'package:frontend/domain/entities/event.dart';
import 'package:frontend/domain/interfaces/event_repository.dart';

class CreateEventUseCase {
  final EventRepository eventRepository;

  CreateEventUseCase(this.eventRepository);

  /// Crea un nuevo evento y devuelve el ID del evento creado.
  Future<String?> execute(Event event) async {
    try {
      return await eventRepository.createEvent(event);
    } catch (e) {
      throw Exception('Error al crear el evento: $e');
    }
  }
}
