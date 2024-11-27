// relative path: frontend/lib/application/use_cases/calendars/remove_event_from_calendar_use_case.dart

import 'package:frontend/domain/interfaces/calendar_repository.dart';

class RemoveEventFromCalendarUseCase {
  final CalendarRepository calendarRepository;

  RemoveEventFromCalendarUseCase(this.calendarRepository);

  /// Elimina un evento de un calendario llamando al método correspondiente en el repositorio.
  Future<bool> execute(String calendarId, String eventId) async {
    try {
      return await calendarRepository.removeEventFromCalendar(
          calendarId, eventId);
    } catch (e) {
      print('Error al eliminar el evento del calendario: $e');
      return false;
    }
  }
}
