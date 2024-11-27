// relative path: frontend/lib/application/use_cases/calendars/list_public_calendars_use_case.dart

import 'package:frontend/domain/entities/calendar.dart';
import 'package:frontend/domain/interfaces/calendar_repository.dart';

class ListPublicCalendarsUseCase {
  final CalendarRepository calendarRepository;

  ListPublicCalendarsUseCase(this.calendarRepository);

  /// Lista calendarios públicos con soporte para paginación llamando al método correspondiente en el repositorio.
  Future<List<Calendar>> execute({int page = 1, int limit = 10}) async {
    try {
      return await calendarRepository.listPublicCalendars(
          page: page, limit: limit);
    } catch (e) {
      print('Error al listar los calendarios públicos: $e');
      return [];
    }
  }
}
