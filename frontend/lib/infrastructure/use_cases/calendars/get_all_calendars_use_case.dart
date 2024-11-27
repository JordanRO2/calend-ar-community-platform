// relative path: frontend/lib/application/use_cases/calendars/get_all_calendars_use_case.dart

import 'package:frontend/domain/entities/calendar.dart';
import 'package:frontend/domain/interfaces/calendar_repository.dart';

class GetAllCalendarsUseCase {
  final CalendarRepository calendarRepository;

  GetAllCalendarsUseCase(this.calendarRepository);

  /// Obtiene una lista de todos los calendarios con soporte para paginación.
  Future<List<Calendar>> execute({int page = 1, int limit = 10}) async {
    try {
      return await calendarRepository.getAllCalendars(page: page, limit: limit);
    } catch (e) {
      print('Error al obtener todos los calendarios: $e');
      return [];
    }
  }
}
