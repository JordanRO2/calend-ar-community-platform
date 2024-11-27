// relative path: frontend/lib/application/use_cases/calendars/update_calendar_use_case.dart

import 'package:frontend/domain/entities/calendar.dart';
import 'package:frontend/domain/interfaces/calendar_repository.dart';

class UpdateCalendarUseCase {
  final CalendarRepository calendarRepository;

  UpdateCalendarUseCase(this.calendarRepository);

  /// Actualiza un calendario existente llamando al método correspondiente en el repositorio.
  Future<bool> execute(String calendarId, Calendar calendar) async {
    try {
      return await calendarRepository.updateCalendar(calendarId, calendar);
    } catch (e) {
      print('Error al actualizar el calendario: $e');
      return false;
    }
  }
}
