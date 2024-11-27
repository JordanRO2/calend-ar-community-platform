// relative path: frontend/lib/application/use_cases/calendars/share_calendar_use_case.dart

import 'package:frontend/domain/interfaces/calendar_repository.dart';

class ShareCalendarUseCase {
  final CalendarRepository calendarRepository;

  ShareCalendarUseCase(this.calendarRepository);

  /// Genera una URL pública para compartir un calendario llamando al método correspondiente en el repositorio.
  Future<String?> execute(String calendarId) async {
    try {
      return await calendarRepository.shareCalendar(calendarId);
    } catch (e) {
      print('Error al generar URL para compartir el calendario: $e');
      return null;
    }
  }
}
