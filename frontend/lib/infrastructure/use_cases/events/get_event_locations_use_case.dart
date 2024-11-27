// frontend/lib/infrastructure/use_cases/events/get_event_locations_use_case.dart

import 'package:frontend/domain/interfaces/event_repository.dart';

class GetEventLocationsUseCase {
  final EventRepository eventRepository;

  GetEventLocationsUseCase(this.eventRepository);

  Future<List<String>> execute() async {
    try {
      return await eventRepository.getLocations();
    } catch (e) {
      throw Exception('Error al obtener ubicaciones: $e');
    }
  }
}
