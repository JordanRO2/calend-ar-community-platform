// relative path: frontend/lib/application/use_cases/calendars/delete_calendar_use_case.dart

import 'package:frontend/domain/interfaces/calendar_repository.dart';

class DeleteCalendarUseCase {
  final CalendarRepository calendarRepository;

  DeleteCalendarUseCase(this.calendarRepository);

  /// Elimina un calendario llamando al método correspondiente en el repositorio.
  Future<bool> execute(String calendarId) async {
    try {
      return await calendarRepository.deleteCalendar(calendarId);
    } catch (e) {
      print('Error al eliminar el calendario: $e');
      return false;
    }
  }
}
