// relative path: frontend/lib/application/use_cases/calendars/set_event_reminder_use_case.dart

import 'package:frontend/domain/interfaces/calendar_repository.dart';

class SetEventReminderUseCase {
  final CalendarRepository calendarRepository;

  SetEventReminderUseCase(this.calendarRepository);

  /// Configura un recordatorio para un evento en un calendario llamando al método correspondiente en el repositorio.
  Future<bool> execute(String calendarId, String eventId,
      Map<String, dynamic> reminderData) async {
    try {
      return await calendarRepository.setEventReminder(
          calendarId, eventId, reminderData);
    } catch (e) {
      print('Error al configurar el recordatorio para el evento: $e');
      return false;
    }
  }
}
