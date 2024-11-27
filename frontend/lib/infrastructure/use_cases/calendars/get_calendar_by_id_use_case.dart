// relative path: frontend/lib/application/use_cases/calendars/get_calendar_by_id_use_case.dart

import 'package:frontend/domain/entities/calendar.dart';
import 'package:frontend/domain/interfaces/calendar_repository.dart';

class GetCalendarByIdUseCase {
  final CalendarRepository calendarRepository;

  GetCalendarByIdUseCase(this.calendarRepository);

  /// Obtiene un calendario específico por su ID llamando al método correspondiente en el repositorio.
  Future<Calendar?> execute(String calendarId) async {
    try {
      return await calendarRepository.getCalendarById(calendarId);
    } catch (e) {
      print('Error al obtener el calendario por ID: $e');
      return null;
    }
  }
}
