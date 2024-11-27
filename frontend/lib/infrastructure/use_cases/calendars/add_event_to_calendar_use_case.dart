// relative path: frontend/lib/application/use_cases/calendars/add_event_to_calendar_use_case.dart

import 'package:frontend/domain/interfaces/calendar_repository.dart';

class AddEventToCalendarUseCase {
  final CalendarRepository calendarRepository;

  AddEventToCalendarUseCase(this.calendarRepository);

  /// Añade un evento a un calendario llamando al método correspondiente en el repositorio.
  Future<bool> execute(String calendarId, String eventId) async {
    try {
      return await calendarRepository.addEventToCalendar(calendarId, eventId);
    } catch (e) {
      print('Error al añadir el evento al calendario: $e');
      return false;
    }
  }
}
