// frontend/lib/infrastructure/use_cases/events/get_event_categories_use_case.dart

import 'package:frontend/domain/interfaces/event_repository.dart';

class GetEventCategoriesUseCase {
  final EventRepository eventRepository;

  GetEventCategoriesUseCase(this.eventRepository);

  Future<List<String>> execute() async {
    try {
      return await eventRepository.getCategories();
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }
}
