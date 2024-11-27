// frontend/lib/infrastructure/use_cases/events/get_event_types_use_case.dart

import 'package:frontend/domain/interfaces/event_repository.dart';

class GetEventTypesUseCase {
  final EventRepository eventRepository;

  GetEventTypesUseCase(this.eventRepository);

  Future<List<String>> execute() async {
    try {
      return await eventRepository.getTypes();
    } catch (e) {
      throw Exception('Error al obtener tipos: $e');
    }
  }
}
